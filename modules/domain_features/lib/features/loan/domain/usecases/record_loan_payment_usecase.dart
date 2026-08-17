import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';
import 'get_loan_outstanding_balance_usecase.dart';

/// Input for [RecordLoanPaymentUseCase].
class RecordLoanPaymentParams {
  final String loanId;

  /// Debited (repay) or credited (collect).
  final String walletId;
  final int amount;
  final String? note;
  final DateTime date;

  const RecordLoanPaymentParams({
    required this.loanId,
    required this.walletId,
    required this.amount,
    this.note,
    required this.date,
  });
}

/// Records a Trả nợ (on a borrow loan) / Thu nợ (on a lend loan) settlement
/// leg against an existing loan.
///
/// Trả nợ mirrors expense: debits the paying wallet, blocked if it exceeds
/// the wallet's book balance. Thu nợ mirrors income/`_recordReturn`: credits
/// the collecting wallet, no balance check. Both are rejected if the amount
/// exceeds the loan's current outstanding balance, or if the loan is already
/// settled.
@lazySingleton
class RecordLoanPaymentUseCase {
  RecordLoanPaymentUseCase(
    this._loanRepository,
    this._transactionRepository,
    this._getLoanOutstandingBalance,
    this._getWalletBookBalance,
  );

  final LoanRepository _loanRepository;
  final TransactionRepository _transactionRepository;
  final GetLoanOutstandingBalanceUseCase _getLoanOutstandingBalance;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  Future<Result<LoanEntity, CcFailure>> call(
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

    final loanResult = await _loanRepository.getLoan(params.loanId);
    if (loanResult.isError()) {
      return Error(loanResult.tryGetError()!);
    }
    final loan = loanResult.tryGetSuccess()!;

    final outstandingResult = await _getLoanOutstandingBalance(params.loanId);
    if (outstandingResult.isError()) {
      return Error(outstandingResult.tryGetError()!);
    }
    final outstanding = outstandingResult.tryGetSuccess()!;
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

    if (loan.isBorrow) {
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

    final txn = TransactionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: loan.isBorrow
          ? TransactionType.debtRepay
          : TransactionType.debtCollect,
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
    final updatedLoan = LoanEntity(
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
    await _loanRepository.updateLoan(updatedLoan);

    return Success(updatedLoan);
  }
}
