import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/helper/monthly_bill_suggestion_helper.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

@lazySingleton
class GetMonthlyRecurringMatchUseCase {
  GetMonthlyRecurringMatchUseCase(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<Result<TransactionEntity?, CcFailure>> call({
    required String type,
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final window = monthlyBillWindow(today);
    final result = await _transactionRepository.getTransactionsByPeriod(
      window.start,
      window.end,
    );
    if (result.isError()) return Error(result.tryGetError()!);

    final candidates = result
        .tryGetSuccess()!
        .where((t) => t.type == type)
        .toList();
    return Success(findMonthlyBillMatch(now: today, candidates: candidates));
  }
}
