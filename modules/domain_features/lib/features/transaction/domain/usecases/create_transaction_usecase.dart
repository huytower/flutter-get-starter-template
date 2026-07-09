import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Input for [CreateTransactionUseCase].
class CreateTransactionParams {
  /// `'income'` or `'expense'`.
  final String type;
  final int amount;

  /// FK to the selected [CategoryEntity] (expense only).
  final String categoryId;

  /// Denormalized category label stored for display.
  final String categoryLabel;

  final String walletId;
  final String? note;
  final DateTime date;

  const CreateTransactionParams({
    required this.type,
    required this.amount,
    this.categoryId = '',
    this.categoryLabel = '',
    required this.walletId,
    this.note,
    required this.date,
  });
}

/// Records an income/expense transaction — the app's core "nhập Thu/Chi" flow.
///
/// Budget-spend aggregation matches expenses by category + calendar month, so
/// no budget link is stored on the transaction.
@lazySingleton
class CreateTransactionUseCase {
  CreateTransactionUseCase(
    this._transactionRepository,
    this._getWalletBookBalance,
  );

  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  Future<Result<TransactionEntity, CcFailure>> call(
    CreateTransactionParams params,
  ) async {
    if (params.amount <= 0) {
      return const Error(ValidationFailure('Số tiền phải lớn hơn 0!'));
    }
    if (params.walletId.isEmpty) {
      return const Error(ValidationFailure('Vui lòng chọn ví!'));
    }
    if (params.type == 'expense' && params.categoryId.isEmpty) {
      return const Error(ValidationFailure('Vui lòng chọn hạng mục!'));
    }
    // A transaction can't happen in the future — guard in case a caller passes
    // one regardless of the date-picker's bounds.
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure('Không thể ghi giao dịch ở tương lai!'),
      );
    }

    // Block overspending: an expense can't exceed the wallet's book balance
    // (no negative balances). Income is unrestricted.
    if (params.type == 'expense') {
      final balanceResult = await _getWalletBookBalance(params.walletId);
      if (balanceResult.isError()) {
        return Error(balanceResult.tryGetError()!);
      }
      if (params.amount > balanceResult.tryGetSuccess()!) {
        return const Error(ValidationFailure('Số dư ví không đủ!'));
      }
    }

    final transaction = TransactionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: params.type,
      amount: params.amount,
      category: params.categoryLabel,
      categoryId: params.categoryId,
      note: params.note,
      date: params.date,
      walletId: params.walletId,
    );

    final result = await _transactionRepository.createTransaction(transaction);
    if (result.isError()) {
      return Error(result.tryGetError()!);
    }
    return Success(transaction);
  }
}
