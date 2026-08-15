import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CashFlowEntity {
  final int income;
  final int expense;

  const CashFlowEntity({required this.income, required this.expense});

  int get net => income - expense;

  /// Thu ít hơn chi ("thấu chi") — spending more than earning so far this
  /// month.
  bool get isDeficit => net < 0;
}

/// Month-to-date income vs expense — the same window
/// `GetUserLevelStatusUseCase` uses for its cash-flow signal, but as its own
/// lightweight, side-effect-free use case so budget-warning code doesn't
/// need to depend on the heavier level-computation flow (which also writes
/// `highestUserLevelReached`).
@lazySingleton
class GetMonthToDateCashFlowUseCase {
  GetMonthToDateCashFlowUseCase(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<Result<CashFlowEntity, CcFailure>> call() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final result = await _transactionRepository.getTransactionsByPeriod(
      startOfMonth,
      now,
    );
    if (result.isError()) return Error(result.tryGetError()!);

    var income = 0;
    var expense = 0;
    for (final t in result.tryGetSuccess()!) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount;
      }
    }
    return Success(CashFlowEntity(income: income, expense: expense));
  }
}
