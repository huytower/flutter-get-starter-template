import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../repositories/transaction_repository.dart';
import '../services/transaction_legs.dart';

/// Input for [UpdateTransactionUseCase].
class UpdateTransactionParams {
  /// The transaction being corrected — supplies `id`/`type` (unchangeable)
  /// and is compared against to re-derive the wallet's balance without it.
  final TransactionEntity original;

  final int amount;

  /// FK to the selected [CategoryEntity].
  final String categoryId;

  /// Denormalized category label stored for display.
  final String categoryLabel;

  final int? categoryIconCode;
  final String? categoryIconFamily;

  final String? budgetId;

  final String walletId;
  final String? note;
  final DateTime date;

  const UpdateTransactionParams({
    required this.original,
    required this.amount,
    this.categoryId = '',
    this.categoryLabel = '',
    this.categoryIconCode,
    this.categoryIconFamily,
    this.budgetId,
    required this.walletId,
    this.note,
    required this.date,
  });
}

/// Corrects a previously recorded transaction (income, expense, debt/loan,
/// or investment legs).
///
/// Restricted to non-transfer, non-deleted entries dated within the last
/// [transactionEditWindowDays] days, matching the product rule that only
/// recent entries can be fixed. Validation otherwise mirrors
/// [CreateTransactionUseCase].
@lazySingleton
class UpdateTransactionUseCase {
  UpdateTransactionUseCase(
    this._transactionRepository,
    this._walletRepository,
    this._getWalletBookBalance,
    this._conversionService,
    this._legs,
  );

  final TransactionRepository _transactionRepository;
  final TransactionLegs _legs;
  final WalletRepository _walletRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;
  final CurrencyConversionService _conversionService;

  static const _editableTypes = <String>{
    TransactionType.income,
    TransactionType.expense,
    TransactionType.debtBorrow,
    TransactionType.debtLend,
    TransactionType.debtRepay,
    TransactionType.debtCollect,
    TransactionType.investmentOut,
    TransactionType.investmentIn,
    TransactionType.investmentReturn,
  };

  Future<Result<TransactionEntity, CcFailure>> call(
    UpdateTransactionParams params,
  ) async {
    final original = params.original;

    if (!_editableTypes.contains(original.type)) {
      return const Error(
        CcValidationFailure(PrjLocaleKeys.transaction_validation_not_editable),
      );
    }
    if (DateTime.now().difference(original.date).inDays >
        transactionEditWindowDays) {
      return const Error(
        CcValidationFailure(PrjLocaleKeys.transaction_validation_edit_window),
      );
    }
    final legs = await _legs.legsOf(original);
    await _legs.trace('UpdateTransaction', legs);
    if (await _legs.hasReconciled(legs)) {
      return const Error(
        CcValidationFailure(PrjLocaleKeys.transaction_validation_reconciled),
      );
    }
    if (params.amount <= 0) {
      return const Error(
        CcValidationFailure(
          PrjLocaleKeys.transaction_validation_amount_required,
        ),
      );
    }
    if (params.walletId.isEmpty) {
      return const Error(
        CcValidationFailure(
          PrjLocaleKeys.transaction_validation_wallet_required,
        ),
      );
    }
    if (params.categoryId.isEmpty) {
      return const Error(
        CcValidationFailure(
          PrjLocaleKeys.transaction_validation_category_required,
        ),
      );
    }
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        CcValidationFailure(PrjLocaleKeys.transaction_validation_future_date),
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

    if (original.type == TransactionType.expense) {
      final balanceResult = await _getWalletBookBalance(params.walletId);
      if (balanceResult.isError()) {
        return Error(balanceResult.tryGetError()!);
      }
      var availableBalance = balanceResult.tryGetSuccess()!;
      if (original.walletId == params.walletId) {
        availableBalance += original.amount;
      }
      if (finalAmount > availableBalance) {
        return const Error(
          CcValidationFailure(
            PrjLocaleKeys.transaction_validation_insufficient_balance,
          ),
        );
      }
    }

    // Built directly (not `original.copyWith`) so clearing the note to empty
    // actually clears it — `copyWith`'s `??` semantics can't null out a field.
    final updated = TransactionEntity(
      id: original.id,
      type: original.type,
      amount: finalAmount,
      category: params.categoryLabel,
      categoryId: params.categoryId,
      budgetId: params.budgetId,
      categoryIconCode: params.categoryIconCode,
      categoryIconFamily: params.categoryIconFamily,
      note: params.note,
      date: params.date,
      walletId: params.walletId,
      transferId: original.transferId,
      // Keeps the link to the investment position (ROI, wallet-delete cascade).
      investmentWalletId: original.investmentWalletId,
      liabilityId: original.liabilityId,
      lat: original.lat,
      lng: original.lng,
      currencyCode: finalCurrency,
    );

    // A Chi ra leg moves with its mirror leg (cash side ↔ position side).
    final mirrors = await _legs.mirrorsFor(updated);
    if (mirrors.isError()) return Error(mirrors.tryGetError()!);

    final result = await _transactionRepository.updateTransaction(updated);
    if (result.isError()) {
      return Error(result.tryGetError()!);
    }
    for (final mirror in mirrors.tryGetSuccess()!) {
      final saved = await _transactionRepository.updateTransaction(mirror);
      if (saved.isError()) return Error(saved.tryGetError()!);
    }
    await _legs.trace('UpdateTransaction', [
      updated,
      ...mirrors.tryGetSuccess()!,
    ]);
    return Success(updated);
  }
}
