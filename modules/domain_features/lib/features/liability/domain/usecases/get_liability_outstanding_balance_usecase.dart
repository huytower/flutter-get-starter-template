import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../repositories/liability_repository.dart';
import 'liability_balance_calculator.dart';

/// Computes the outstanding balance for a single loan, from its principal and
/// linked repay/collect transactions.
@lazySingleton
class GetLiabilityOutstandingBalanceUseCase {
  GetLiabilityOutstandingBalanceUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
  );

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<int, CcFailure>> call(String loanId) async {
    final loanResult = await _LiabilityRepository.getLoan(loanId);
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


