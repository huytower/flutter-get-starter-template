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

  Future<Result<int, CcFailure>> call(String liabilityId) async {
    final liabilityResult = await _LiabilityRepository.getLiability(
      liabilityId,
    );
    if (liabilityResult.isError()) {
      return Error(liabilityResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getTransactionsByLiability(
      liabilityId,
    );
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final balance = liabilityOutstandingBalance(
      liabilityResult.tryGetSuccess()!.principalAmount,
      txnResult.tryGetSuccess()!,
    );
    return Success(balance);
  }
}
