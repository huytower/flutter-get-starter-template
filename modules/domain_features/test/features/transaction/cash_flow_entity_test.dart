import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_insights_entity.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/usecases/get_monthly_cash_flow_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._transactions);

  final List<TransactionEntity> _transactions;
  DateTime? lastStart;
  DateTime? lastEnd;

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    lastStart = start;
    lastEnd = end;
    return Success(_transactions);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionEntity _txn(String type, int amount) => TransactionEntity(
  id: '${type}_$amount',
  type: type,
  amount: amount,
  category: '',
  date: DateTime.now(),
  walletId: 'w',
);

void main() {
  group('CashFlowEntity', () {
    test('deficit follows income minus expense like the report page', () {
      const flow = CashFlowEntity(
        income: 1000,
        expense: 600,
        debtOutflow: 300,
        investmentOutflow: 200,
      );
      expect(flow.operatingNet, 400);
      expect(flow.net, -100);
      expect(flow.isDeficit, isFalse);

      const overspent = CashFlowEntity(
        income: 500,
        expense: 900,
        debtInflow: 1000,
      );
      expect(overspent.net, 600);
      expect(overspent.operatingNet, -400);
      expect(overspent.isDeficit, isTrue);
    });

    test('borrowed money masks an operating deficit and is flagged', () {
      const flow = CashFlowEntity(income: 500, expense: 900, debtInflow: 1000);
      expect(flow.isDeficit, isTrue);
      expect(flow.net, greaterThan(0));
      expect(flow.isInflowDebtDriven, isTrue);
      expect(flow.debtInflowPercent, 67);
      expect(flow.isOutflowDebtDriven, isFalse);
    });

    test('debt repayment dominating outflow is flagged', () {
      const flow = CashFlowEntity(
        income: 2000,
        expense: 300,
        debtOutflow: 1200,
      );
      expect(flow.isOutflowDebtDriven, isTrue);
      expect(flow.debtOutflowPercent, 80);
      expect(flow.isInflowDebtDriven, isFalse);
    });

    test('small debt share is not flagged', () {
      const flow = CashFlowEntity(income: 2000, expense: 300, debtInflow: 100);
      expect(flow.isInflowDebtDriven, isFalse);
    });

    test('exactly 50% debt share is flagged on both sides', () {
      const flow = CashFlowEntity(
        income: 500,
        expense: 500,
        debtInflow: 500,
        debtOutflow: 500,
      );
      expect(flow.isInflowDebtDriven, isTrue);
      expect(flow.isOutflowDebtDriven, isTrue);
    });

    test('zero totals never flag and never divide by zero', () {
      const flow = CashFlowEntity(income: 0, expense: 0);
      expect(flow.isInflowDebtDriven, isFalse);
      expect(flow.isOutflowDebtDriven, isFalse);
      expect(flow.debtInflowPercent, 0);
      expect(flow.debtOutflowPercent, 0);
    });
  });

  group('GetMonthlyCashFlowUseCase', () {
    test('buckets each transaction type and ignores counter-legs', () async {
      final useCase = GetMonthlyCashFlowUseCase(
        _FakeTransactionRepository([
          _txn(TransactionType.income, 100),
          _txn(TransactionType.expense, 10),
          _txn(TransactionType.debtBorrow, 20),
          _txn(TransactionType.debtCollect, 30),
          _txn(TransactionType.debtLend, 40),
          _txn(TransactionType.debtRepay, 50),
          _txn(TransactionType.investmentReturn, 60),
          _txn(TransactionType.investmentOut, 70),
          _txn(TransactionType.investmentIn, 999),
          _txn(TransactionType.transferIn, 999),
          _txn(TransactionType.transferOut, 999),
        ]),
      );

      final flow = (await useCase.call()).tryGetSuccess()!;

      expect(flow.income, 100);
      expect(flow.expense, 10);
      expect(flow.debtInflow, 50);
      expect(flow.debtOutflow, 90);
      expect(flow.investmentInflow, 60);
      expect(flow.investmentOutflow, 70);
      expect(flow.net, 100 + 50 + 60 - 10 - 90 - 70);
    });
  });

  group('GetMonthlyCashFlowUseCase window', () {
    test('spans the whole calendar month like the report page', () async {
      final repository = _FakeTransactionRepository(const []);
      await GetMonthlyCashFlowUseCase(repository).call();

      final now = DateTime.now();
      expect(repository.lastStart, DateTime(now.year, now.month, 1));
      expect(
        repository.lastEnd,
        DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999),
      );
    });
  });

  group('BudgetInsightsEntity.hasAnything', () {
    BudgetInsightsEntity build({bool inflow = false, bool outflow = false}) =>
        BudgetInsightsEntity(
          pacingWarnings: const [],
          penaltyWarnings: const [],
          isDeficit: false,
          deficitAmount: 0,
          anomalyCount: 0,
          isInflowDebtDriven: inflow,
          isOutflowDebtDriven: outflow,
        );

    test('is true when only a debt flag is set', () {
      expect(build(inflow: true).hasAnything, isTrue);
      expect(build(outflow: true).hasAnything, isTrue);
    });

    test('is false when nothing is set', () {
      expect(build().hasAnything, isFalse);
    });
  });
}
