import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/usecases/get_monthly_recurring_match_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._result);

  final Result<List<TransactionEntity>, CcFailure> _result;
  DateTime? lastStart;
  DateTime? lastEnd;

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    lastStart = start;
    lastEnd = end;
    return _result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionEntity _txn(String type, DateTime date, {String categoryId = 'c'}) =>
    TransactionEntity(
      id: '${date.microsecondsSinceEpoch}_$type',
      type: type,
      amount: 1000,
      category: '',
      categoryId: categoryId,
      date: date,
      walletId: 'w',
    );

void main() {
  final now = DateTime(2026, 10, 18);

  group('GetMonthlyRecurringMatchUseCase', () {
    test('queries last month through the end of this month', () async {
      final repository = _FakeTransactionRepository(const Success([]));

      await GetMonthlyRecurringMatchUseCase(
        repository,
      ).call(type: TransactionType.income, now: now);

      expect(repository.lastStart, DateTime(2026, 9, 1));
      expect(repository.lastEnd, DateTime(2026, 10, 31, 23, 59, 59, 999, 999));
    });

    test('only considers the requested type', () async {
      final income = _txn(TransactionType.income, DateTime(2026, 9, 17));
      final expense = _txn(TransactionType.expense, DateTime(2026, 9, 18));
      final repository = _FakeTransactionRepository(Success([expense, income]));
      final useCase = GetMonthlyRecurringMatchUseCase(repository);

      final incomeMatch = await useCase.call(
        type: TransactionType.income,
        now: now,
      );
      final expenseMatch = await useCase.call(
        type: TransactionType.expense,
        now: now,
      );

      expect(incomeMatch.tryGetSuccess(), income);
      expect(expenseMatch.tryGetSuccess(), expense);
    });

    test(
      'ignores other types when deciding what is recorded this month',
      () async {
        final income = _txn(TransactionType.income, DateTime(2026, 9, 17));
        final expenseSameCategory = _txn(
          TransactionType.expense,
          DateTime(2026, 10, 5),
        );
        final repository = _FakeTransactionRepository(
          Success([income, expenseSameCategory]),
        );

        final result = await GetMonthlyRecurringMatchUseCase(
          repository,
        ).call(type: TransactionType.income, now: now);

        expect(result.tryGetSuccess(), income);
      },
    );

    test('returns a null match when nothing recurs', () async {
      final repository = _FakeTransactionRepository(const Success([]));

      final result = await GetMonthlyRecurringMatchUseCase(
        repository,
      ).call(type: TransactionType.income, now: now);

      expect(result.isSuccess(), isTrue);
      expect(result.tryGetSuccess(), isNull);
    });

    test('propagates repository failures', () async {
      const failure = ServerFailure('boom');
      final repository = _FakeTransactionRepository(const Error(failure));

      final result = await GetMonthlyRecurringMatchUseCase(
        repository,
      ).call(type: TransactionType.income, now: now);

      expect(result.tryGetError(), failure);
    });
  });
}
