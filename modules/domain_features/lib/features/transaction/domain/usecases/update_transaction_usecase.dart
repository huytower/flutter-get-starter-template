import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

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
    this._getWalletBookBalance,
  );

  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

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
        ValidationFailure(CcLocaleKeys.transaction_validation_not_editable),
      );
    }
    if (DateTime.now().difference(original.date).inDays >
        transactionEditWindowDays) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_edit_window),
      );
    }
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
    if (params.categoryId.isEmpty) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_category_required,
        ),
      );
    }
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_future_date),
      );
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
      if (params.amount > availableBalance) {
        return const Error(
          ValidationFailure(
            CcLocaleKeys.transaction_validation_insufficient_balance,
          ),
        );
      }
    }

    // Built directly (not `original.copyWith`) so clearing the note to empty
    // actually clears it — `copyWith`'s `??` semantics can't null out a field.
    final updated = TransactionEntity(
      id: original.id,
      type: original.type,
      amount: params.amount,
      category: params.categoryLabel,
      categoryId: params.categoryId,
      budgetId: params.budgetId,
      categoryIconCode: params.categoryIconCode,
      categoryIconFamily: params.categoryIconFamily,
      note: params.note,
      date: params.date,
      walletId: params.walletId,
      transferId: original.transferId,
      loanId: original.loanId,
      lat: original.lat,
      lng: original.lng,
    );

    final result = await _transactionRepository.updateTransaction(updated);
    if (result.isError()) {
      return Error(result.tryGetError()!);
    }
    return Success(updated);
  }
}
