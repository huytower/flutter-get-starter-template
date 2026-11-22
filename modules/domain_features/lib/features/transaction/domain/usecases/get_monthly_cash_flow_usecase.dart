import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/cash_flow_entity.dart';
import '../repositories/transaction_repository.dart';

@lazySingleton
class GetMonthlyCashFlowUseCase {
  GetMonthlyCashFlowUseCase(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<Result<CashFlowEntity, CcFailure>> call() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    final result = await _transactionRepository.getTransactionsByPeriod(
      startOfMonth,
      endOfMonth,
    );
    if (result.isError()) return Error(result.tryGetError()!);

    var income = 0;
    var expense = 0;
    var debtInflow = 0;
    var debtOutflow = 0;
    var investmentInflow = 0;
    var investmentOutflow = 0;
    for (final t in result.tryGetSuccess()!) {
      switch (t.type) {
        case TransactionType.income:
          income += t.amount;
        case TransactionType.expense:
          expense += t.amount;
        case TransactionType.debtBorrow:
        case TransactionType.debtCollect:
          debtInflow += t.amount;
        case TransactionType.debtLend:
        case TransactionType.debtRepay:
          debtOutflow += t.amount;
        case TransactionType.investmentReturn:
          investmentInflow += t.amount;
        case TransactionType.investmentOut:
          investmentOutflow += t.amount;
      }
    }
    return Success(
      CashFlowEntity(
        income: income,
        expense: expense,
        debtInflow: debtInflow,
        debtOutflow: debtOutflow,
        investmentInflow: investmentInflow,
        investmentOutflow: investmentOutflow,
      ),
    );
  }
}
