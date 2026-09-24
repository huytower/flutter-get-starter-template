import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/liability_entity.dart';
import '../repositories/liability_repository.dart';

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

  const RecordLiabilityPaymentParams({
    required this.liabilityId,
    this.isSettlement = true,
    required this.walletId,
    required this.amount,
    this.note,
    required this.date,
  });
}

/// Records a payment leg: Repayment / Collection (decrease) or Borrowing / Lending (increase)
/// against a selected liability category (e.g., "Nợ thẻ tín dụng", "Vay thế chấp").
///
/// Users manage their debts freely without restrictive settlement guards
/// (no limits on repayments or borrowings, allowing revolving credit management).
@lazySingleton
class RecordLiabilityPaymentUseCase {
  RecordLiabilityPaymentUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
    this._getWalletBookBalance,
  );

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

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

    final liabilityResult = await _LiabilityRepository.getLiability(
      params.liabilityId,
    );
    if (liabilityResult.isError()) {
      return Error(liabilityResult.tryGetError()!);
    }
    final liability = liabilityResult.tryGetSuccess()!;

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
      if (params.amount > availableBalance) {
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
      amount: params.amount,
      category: liability.categoryLabel,
      categoryId: liability.categoryId,
      categoryIconCode: liability.categoryIconCode,
      categoryIconFamily: liability.categoryIconFamily,
      note: params.note,
      date: params.date,
      walletId: params.walletId,
      liabilityId: liability.id,
    );

    final txnResult = await _transactionRepository.createTransaction(txn);
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
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
    );
    await _LiabilityRepository.updateLiability(updatedLiability);

    return Success(updatedLiability);
  }
}
