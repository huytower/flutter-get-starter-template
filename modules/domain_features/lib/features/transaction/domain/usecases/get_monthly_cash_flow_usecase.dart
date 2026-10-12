import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CashFlowEntity {
  final int income;
  final int expense;
  final int debtInflow;
  final int debtOutflow;
  final int investmentInflow;
  final int investmentOutflow;

  const CashFlowEntity({
    required this.income,
    required this.expense,
    this.debtInflow = 0,
    this.debtOutflow = 0,
    this.investmentInflow = 0,
    this.investmentOutflow = 0,
  });

  static const double debtDominanceThreshold = 0.5;

  int get totalInflow => income + debtInflow + investmentInflow;

  int get totalOutflow => expense + debtOutflow + investmentOutflow;

  int get net => totalInflow - totalOutflow;

  int get operatingNet => income - expense;

  bool get isDeficit => operatingNet < 0;

  int get debtInflowPercent =>
      totalInflow == 0 ? 0 : (debtInflow * 100 / totalInflow).round();

  int get debtOutflowPercent =>
      totalOutflow == 0 ? 0 : (debtOutflow * 100 / totalOutflow).round();

  bool get isInflowDebtDriven =>
      debtInflow > 0 && debtInflow >= totalInflow * debtDominanceThreshold;

  bool get isOutflowDebtDriven =>
      debtOutflow > 0 && debtOutflow >= totalOutflow * debtDominanceThreshold;
}

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
