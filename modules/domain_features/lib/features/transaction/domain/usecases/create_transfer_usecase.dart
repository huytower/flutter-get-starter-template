import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Input for [CreateTransferUseCase].
class CreateTransferParams {
  final String fromWalletId;
  final String toWalletId;
  final int amount;
  final String? note;
  final DateTime date;

  const CreateTransferParams({
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    this.note,
    required this.date,
  });
}

/// Moves money between two wallets ("Chuyển khoản").
///
/// A transfer is neither income nor expense — it doesn't change net worth, only
/// where the money sits. It's stored as two linked legs sharing a `transferId`:
/// a [TransactionType.transferOut] on the source wallet and a
/// [TransactionType.transferIn] on the destination. The pair is created
/// atomically; if the second leg fails, the first is rolled back.
@lazySingleton
class CreateTransferUseCase {
  CreateTransferUseCase(
    this._transactionRepository,
    this._getWalletBookBalance,
  );

  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  /// Denormalized label stored on both legs for any future display.
  /// (Note: this should ideally be passed in or translated at the UI layer)
  static const String _label = 'Chuyển khoản';

  Future<Result<void, CcFailure>> call(CreateTransferParams params) async {
    if (params.amount <= 0) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_amount_required),
      );
    }
    if (params.fromWalletId.isEmpty || params.toWalletId.isEmpty) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_wallet_required),
      );
    }
    if (params.fromWalletId == params.toWalletId) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_same_wallet_transfer,
        ),
      );
    }
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_future_date),
      );
    }

    // No overdraft — the source wallet must hold enough (same rule as expenses).
    final balanceResult = await _getWalletBookBalance(params.fromWalletId);
    if (balanceResult.isError()) {
      return Error(balanceResult.tryGetError()!);
    }
    if (params.amount > balanceResult.tryGetSuccess()!) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_insufficient_balance,
        ),
      );
    }

    final transferId = DateTime.now().microsecondsSinceEpoch.toString();
    final outLeg = TransactionEntity(
      id: '${transferId}_out',
      type: TransactionType.transferOut,
      amount: params.amount,
      category: _label,
      note: params.note,
      date: params.date,
      walletId: params.fromWalletId,
      transferId: transferId,
    );
    final inLeg = TransactionEntity(
      id: '${transferId}_in',
      type: TransactionType.transferIn,
      amount: params.amount,
      category: _label,
      note: params.note,
      date: params.date,
      walletId: params.toWalletId,
      transferId: transferId,
    );

    final outResult = await _transactionRepository.createTransaction(outLeg);
    if (outResult.isError()) {
      return Error(outResult.tryGetError()!);
    }

    final inResult = await _transactionRepository.createTransaction(inLeg);
    if (inResult.isError()) {
      // Roll back the out leg so the transfer is all-or-nothing.
      await _transactionRepository.deleteTransaction(outLeg.id);
      return Error(inResult.tryGetError()!);
    }

    return const Success(null);
  }
}
