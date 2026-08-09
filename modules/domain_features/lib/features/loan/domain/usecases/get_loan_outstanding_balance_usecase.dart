import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../repositories/loan_repository.dart';
import 'loan_balance_calculator.dart';

/// Computes the outstanding balance for a single loan, from its principal and
/// linked repay/collect transactions.
@lazySingleton
class GetLoanOutstandingBalanceUseCase {
  GetLoanOutstandingBalanceUseCase(
    this._loanRepository,
    this._transactionRepository,
  );

  final LoanRepository _loanRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<int, CcFailure>> call(String loanId) async {
    final loanResult = await _loanRepository.getLoan(loanId);
    if (loanResult.isError()) {
      return Error(loanResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getTransactionsByLoan(
      loanId,
    );
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final balance = loanOutstandingBalance(
      loanResult.tryGetSuccess()!.principalAmount,
      txnResult.tryGetSuccess()!,
    );
    return Success(balance);
  }
}
