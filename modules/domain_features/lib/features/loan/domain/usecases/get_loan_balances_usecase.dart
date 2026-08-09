import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/loan_balance_entity.dart';
import '../repositories/loan_repository.dart';
import 'loan_balance_calculator.dart';

/// Computes the outstanding balance for every loan — backs the Settle-mode
/// outstanding-loans picker and (later) an outstanding-debt report.
@lazySingleton
class GetLoanBalancesUseCase {
  GetLoanBalancesUseCase(this._loanRepository, this._transactionRepository);

  final LoanRepository _loanRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<List<LoanBalanceEntity>, CcFailure>> call() async {
    final loansResult = await _loanRepository.getLoans();
    if (loansResult.isError()) {
      return Error(loansResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final transactions = txnResult.tryGetSuccess()!;
    final balances = loansResult.tryGetSuccess()!.map((loan) {
      final loanTxns = transactions
          .where((t) => t.loanId == loan.id)
          .toList();
      return LoanBalanceEntity(
        loan: loan,
        outstandingBalance: loanOutstandingBalance(
          loan.principalAmount,
          loanTxns,
        ),
      );
    }).toList();

    return Success(balances);
  }
}
