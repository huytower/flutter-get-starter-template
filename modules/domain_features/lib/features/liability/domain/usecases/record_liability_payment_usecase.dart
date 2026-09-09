import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/liability_entity.dart';
import '../repositories/liability_repository.dart';
import 'get_liability_outstanding_balance_usecase.dart';

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

/// Records a settlement leg (Trả nợ / Thu nợ) or an incremental leg
/// (Vay thêm / Cho vay thêm) against an existing liability.
///
/// Settlements decrease the outstanding balance and are blocked if the amount
/// exceeds it. Incremental legs increase the balance and have no liability-side
/// limit. Both respect standard wallet balance guards for outflows (Chi ra).
@lazySingleton
class RecordLiabilityPaymentUseCase {
  RecordLiabilityPaymentUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
    this._getLiabilityOutstandingBalance,
    this._getWalletBookBalance,
  );

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final GetLiabilityOutstandingBalanceUseCase _getLiabilityOutstandingBalance;
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

    final outstandingResult = await _getLiabilityOutstandingBalance(
      params.liabilityId,
    );
    if (outstandingResult.isError()) {
      return Error(outstandingResult.tryGetError()!);
    }
    final outstanding = outstandingResult.tryGetSuccess()!;

    if (params.isSettlement) {
      if (outstanding <= 0) {
        return const Error(
          ValidationFailure(
            CcLocaleKeys.transaction_validation_liability_settled,
          ),
        );
      }
      if (params.amount > outstanding) {
        return const Error(
          ValidationFailure(
            CcLocaleKeys.transaction_validation_amount_exceeds_outstanding,
          ),
        );
      }
    }

    final isOutflow =
        (liability.isBorrow && params.isSettlement) ||
        (!liability.isBorrow && !params.isSettlement);

    if (isOutflow) {
      final balanceResult = await _getWalletBookBalance(params.walletId);
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
