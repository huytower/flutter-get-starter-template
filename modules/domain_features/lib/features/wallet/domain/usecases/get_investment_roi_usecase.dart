import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';

/// System-wide investment ROI = Σ Thu vào (`investmentReturn`, realized
/// profit) ÷ Σ Chi ra (`investmentOut`, contributed capital). Both types are
/// exclusively written by the Investment flow, so a plain type filter over
/// every transaction is sufficient — no need to resolve which wallets are
/// investment positions first.
@lazySingleton
class GetInvestmentRoiUseCase {
  GetInvestmentRoiUseCase(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<Result<({int totalContributed, int totalReturned}), CcFailure>>
  call() async {
    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final transactions = txnResult.tryGetSuccess()!;
    final totalContributed = transactions
        .where((t) => t.type == TransactionType.investmentOut)
        .fold(0, (sum, t) => sum + t.amount);
    final totalReturned = transactions
        .where((t) => t.type == TransactionType.investmentReturn)
        .fold(0, (sum, t) => sum + t.amount);

    return Success((
      totalContributed: totalContributed,
      totalReturned: totalReturned,
    ));
  }
}
