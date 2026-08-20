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
class RecordLoanPaymentParams {
  final String loanId;

  /// Whether this leg increases (Borrow/Lend) or decreases (Repay/Collect)
  /// the outstanding balance. Defaults to `true` (decrease).
  final bool isSettlement;

  /// Debited (repay/lend) or credited (collect/borrow).
  final String walletId;
  final int amount;
  final String? note;
  final DateTime date;

  const RecordLoanPaymentParams({
    required this.loanId,
    this.isSettlement = true,
    required this.walletId,
    required this.amount,
    this.note,
    required this.date,
  });
}

/// Records a settlement leg (Trả nợ / Thu nợ) or an incremental leg
/// (Vay thêm / Cho vay thêm) against an existing loan.
///
/// Settlements decrease the outstanding balance and are blocked if the amount
/// exceeds it. Incremental legs increase the balance and have no loan-side
/// limit. Both respect standard wallet balance guards for outflows (Chi ra).
@lazySingleton
class RecordLiabilityPaymentUseCase {
  RecordLiabilityPaymentUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
    this._getLoanOutstandingBalance,
    this._getWalletBookBalance,
  );

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final GetLiabilityOutstandingBalanceUseCase _getLoanOutstandingBalance;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  Future<Result<LiabilityEntity, CcFailure>> call(
    RecordLoanPaymentParams params,
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

    final loanResult = await _LiabilityRepository.getLoan(params.loanId);
    if (loanResult.isError()) {
      return Error(loanResult.tryGetError()!);
    }
    final loan = loanResult.tryGetSuccess()!;

    final outstandingResult = await _getLoanOutstandingBalance(params.loanId);
    if (outstandingResult.isError()) {
      return Error(outstandingResult.tryGetError()!);
    }
    final outstanding = outstandingResult.tryGetSuccess()!;

    if (params.isSettlement) {
      if (outstanding <= 0) {
        return const Error(
          ValidationFailure(CcLocaleKeys.transaction_validation_loan_settled),
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
        (loan.isBorrow && params.isSettlement) ||
        (!loan.isBorrow && !params.isSettlement);

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
    if (loan.isBorrow) {
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
      category: loan.categoryLabel,
      categoryId: loan.categoryId,
      categoryIconCode: loan.categoryIconCode,
      categoryIconFamily: loan.categoryIconFamily,
      note: params.note,
      date: params.date,
      walletId: params.walletId,
      loanId: loan.id,
    );

    final txnResult = await _transactionRepository.createTransaction(txn);
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    // High Priority Logic: Update updatedAt so this loan jumps to the front
    // of the list on the dashboard next time.
    final updatedLoan = LiabilityEntity(
      id: loan.id,
      direction: loan.direction,
      principalAmount: loan.principalAmount,
      categoryId: loan.categoryId,
      categoryLabel: loan.categoryLabel,
      categoryIconCode: loan.categoryIconCode,
      categoryIconFamily: loan.categoryIconFamily,
      walletId: loan.walletId,
      repaymentMethod: loan.repaymentMethod,
      installments: loan.installments,
      finalDueDate: loan.finalDueDate,
      note: loan.note,
      createdAt: loan.createdAt,
      updatedAt: DateTime.now(),
      reminderBeforeDueDate: loan.reminderBeforeDueDate,
    );
    await _LiabilityRepository.updateLoan(updatedLoan);

    return Success(updatedLoan);
  }
}
