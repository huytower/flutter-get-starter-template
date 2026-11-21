import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../repositories/liability_repository.dart';
import 'get_liability_balances_usecase.dart';

/// Input for [RecordLiabilityPaymentUseCase].
class RecordLiabilityPaymentParams {
  final String liabilityId;

  /// Whether this leg increases (Borrow/Lend) or decreases (Repay/Collect)
  /// the outstanding balance. Defaults to `true` (decrease).
  final bool isSettlement;

  /// Debited (repay/lend) or credited (collect/borrow).
  final String walletId;
  final int amount;
  final String? note;
  final DateTime date;

  /// The liability as the form lists it. `GetLiabilityBalancesUseCase` rebuilds
  /// debt transactions that have no stored record into a synthetic liability;
  /// such a liability is not in the repository, so this entity is used instead.
  final LiabilityEntity? listedLiability;

  /// What is still owed on the liability, in its own currency, as the form
  /// lists it. A settlement (repay / collect) may not exceed it; null skips
  /// the check (no balance known).
  final int? outstandingBalance;

  const RecordLiabilityPaymentParams({
    required this.liabilityId,
    this.isSettlement = true,
    required this.walletId,
    required this.amount,
    this.note,
    required this.date,
    this.listedLiability,
    this.outstandingBalance,
  });
}

/// Records a payment leg: Repayment / Collection (decrease) or Borrowing / Lending (increase)
/// against a selected liability category (e.g., "Nợ thẻ tín dụng", "Vay thế chấp").
@lazySingleton
class RecordLiabilityPaymentUseCase {
  RecordLiabilityPaymentUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
    this._walletRepository,
    this._getWalletBookBalance,
    this._conversionService,
  );

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;
  final CurrencyConversionService _conversionService;

  Future<Result<LiabilityEntity, CcFailure>> call(
    RecordLiabilityPaymentParams params,
  ) async {
    if (params.amount <= 0) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_amount_required),
      );
    }
    if (params.walletId.isEmpty) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_wallet_required),
      );
    }
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_future_date),
      );
    }

    final liabilityResult = await _LiabilityRepository.findLiability(
      params.liabilityId,
    );
    if (liabilityResult.isError()) {
      return Error(liabilityResult.tryGetError()!);
    }
    final stored = liabilityResult.tryGetSuccess();
    final listed = params.listedLiability;
    final LiabilityEntity liability;
    if (stored != null) {
      liability = stored;
    } else if (listed != null && listed.id == params.liabilityId) {
      // Synthetic liability: its balance lives only in its transactions, so
      // the new leg is recorded as one more transaction of that group.
      '[LIABILITY] No stored record for ${params.liabilityId}, recording against the listed (synthetic) liability'
          .Log(runtimeType.toString());
      liability = listed;
    } else {
      '[LIABILITY] ❌ Liability ${params.liabilityId} not found'.Log(
        runtimeType.toString(),
      );
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_liability_not_found),
      );
    }

    final outstanding = params.outstandingBalance;
    if (params.isSettlement &&
        outstanding != null &&
        await _inCurrencyOf(liability, params.amount) > outstanding) {
      '[LIABILITY] ❌ Settlement ${params.amount} exceeds outstanding $outstanding | liabilityId=${liability.id}'
          .Log(runtimeType.toString());
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_liability_exceeds_outstanding,
        ),
      );
    }

    final walletResult = await _walletRepository.getWallet(params.walletId);
    if (walletResult.isError()) {
      return Error(walletResult.tryGetError()!);
    }
    final wallet = walletResult.tryGetSuccess()!;

    final inputCurrency = CurrencyConstants.currentPrimaryCurrency;
    int finalAmount = params.amount;
    String finalCurrency = wallet.currencyCode;

    if (inputCurrency.toUpperCase() != wallet.currencyCode.toUpperCase()) {
      final convResult = await _conversionService.convertAmount(
        amount: params.amount,
        fromCurrency: inputCurrency,
        toCurrency: wallet.currencyCode,
      );
      if (convResult.isSuccess()) {
        finalAmount = convResult.tryGetSuccess()!;
      }
    }

    final String txnType;
    if (liability.isBorrow) {
      txnType = params.isSettlement
          ? TransactionType.debtRepay
          : TransactionType.debtBorrow;
    } else {
      txnType = params.isSettlement
          ? TransactionType.debtCollect
          : TransactionType.debtLend;
    }

    // Check insufficient wallet balance for transactions where money leaves the wallet
    final isMoneyLeavingWallet =
        (liability.isBorrow && params.isSettlement) ||
        (liability.isLend && !params.isSettlement);

    if (isMoneyLeavingWallet) {
      final balanceResult = await _getWalletBookBalance(params.walletId);
      if (balanceResult.isError()) {
        return Error(balanceResult.tryGetError()!);
      }
      final availableBalance = balanceResult.tryGetSuccess()!;
      if (finalAmount > availableBalance) {
        return const Error(
          ValidationFailure(
            CcLocaleKeys.transaction_validation_insufficient_balance,
          ),
        );
      }
    }

    final txn = TransactionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: txnType,
      amount: finalAmount,
      category: liability.categoryLabel,
      categoryId: liability.categoryId,
      categoryIconCode: liability.categoryIconCode,
      categoryIconFamily: liability.categoryIconFamily,
      note: params.note,
      date: params.date,
      walletId: params.walletId,
      // An id made up for a synthetic group matches nothing; leaving it out
      // lets the transaction join its group by category label.
      liabilityId: liability.id.startsWith(syntheticLiabilityIdPrefix)
          ? null
          : liability.id,
      currencyCode: finalCurrency,
    );

    final txnResult = await _transactionRepository.createTransaction(txn);
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    // A synthetic liability has no record to update (writing one would also
    // count its principal twice); the new transaction already sorts it first.
    if (stored == null) {
      return Success(liability.copyWith(updatedAt: DateTime.now()));
    }

    // High Priority Logic: Update updatedAt so this liability jumps to the front
    // of the list on the dashboard next time.
    final updatedLiability = LiabilityEntity(
      id: liability.id,
      direction: liability.direction,
      principalAmount: liability.principalAmount,
      categoryId: liability.categoryId,
      categoryLabel: liability.categoryLabel,
      categoryIconCode: liability.categoryIconCode,
      categoryIconFamily: liability.categoryIconFamily,
      walletId: liability.walletId,
      repaymentMethod: liability.repaymentMethod,
      installments: liability.installments,
      finalDueDate: liability.finalDueDate,
      note: liability.note,
      createdAt: liability.createdAt,
      updatedAt: DateTime.now(),
      reminderBeforeDueDate: liability.reminderBeforeDueDate,
      currencyCode: liability.currencyCode,
    );
    await _LiabilityRepository.updateLiability(updatedLiability);

    return Success(updatedLiability);
  }

  /// [amount], typed in the primary currency, in [liability]'s currency (the
  /// currency its outstanding balance is kept in). Unchanged if conversion
  /// fails.
  Future<int> _inCurrencyOf(LiabilityEntity liability, int amount) async {
    final from = CurrencyConstants.currentPrimaryCurrency;
    if (from.toUpperCase() == liability.currencyCode.toUpperCase()) {
      return amount;
    }
    final converted = await _conversionService.convertAmount(
      amount: amount,
      fromCurrency: from,
      toCurrency: liability.currencyCode,
    );
    return converted.tryGetSuccess() ?? amount;
  }
}
