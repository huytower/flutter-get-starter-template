import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_limit_entity.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_limit_lock_reason.dart';
import 'package:domain_features/features/budget_limit/domain/services/budget_limit_edit_policy.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._transactions, {this.hasFailed = false});

  final List<TransactionEntity> _transactions;
  final bool hasFailed;

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    if (hasFailed) return const Error(CcValidationFailure('storage'));
    return Success(
      _transactions
          .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
          .toList(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _budget = BudgetLimitEntity(
  id: 'b1',
  categoryId: 'food',
  name: 'Food',
  limit: 1000000,
);

TransactionEntity _txn({
  required DateTime date,
  String type = TransactionType.expense,
  String categoryId = 'food',
  DateTime? deletedAt,
}) => TransactionEntity(
  id: '${type}_${categoryId}_${date.toIso8601String()}',
  type: type,
  amount: 50000,
  category: '',
  categoryId: categoryId,
  date: date,
  walletId: 'cash',
  deletedAt: deletedAt,
);

Future<BudgetLimitLockReason?> _reason(
  List<TransactionEntity> transactions, {
  required DateTime now,
  bool hasFailed = false,
}) => BudgetLimitEditPolicy(
  _FakeTransactionRepository(transactions, hasFailed: hasFailed),
).lockReasonFor(_budget, now: now);

void main() {
  final firstWeek = DateTime(2026, 11, 5, 10);

  group('BudgetLimitEditPolicy', () {
    test('editable in days 1-7 with no spending this month', () async {
      expect(await _reason(const [], now: firstWeek), isNull);
    });

    test('day 7 is still editable, day 8 is locked', () async {
      expect(await _reason(const [], now: DateTime(2026, 11, 7, 23)), isNull);
      expect(
        await _reason(const [], now: DateTime(2026, 11, 8)),
        BudgetLimitLockReason.pastFirstWeek,
      );
    });

    test('an expense in the category this month locks the limit', () async {
      expect(
        await _reason([_txn(date: DateTime(2026, 11, 2))], now: firstWeek),
        BudgetLimitLockReason.hasSpending,
      );
    });

    test('a future-dated expense later this month also counts', () async {
      expect(
        await _reason([_txn(date: DateTime(2026, 11, 20))], now: firstWeek),
        BudgetLimitLockReason.hasSpending,
      );
    });

    test('spending that does not belong to this budget is ignored', () async {
      final reason = await _reason([
        _txn(date: DateTime(2026, 10, 30)), // last month
        _txn(date: DateTime(2026, 12, 1)), // next month
        _txn(date: DateTime(2026, 11, 2), categoryId: 'transport'),
        _txn(date: DateTime(2026, 11, 2), type: TransactionType.income),
        _txn(date: DateTime(2026, 11, 2), deletedAt: DateTime(2026, 11, 3)),
      ], now: firstWeek);
      expect(reason, isNull);
    });

    test('locks when transactions cannot be read', () async {
      expect(
        await _reason(const [], now: firstWeek, hasFailed: true),
        BudgetLimitLockReason.hasSpending,
      );
    });

    test('dayLockReason needs no transactions', () {
      expect(BudgetLimitEditPolicy.dayLockReason(now: firstWeek), isNull);
      expect(
        BudgetLimitEditPolicy.dayLockReason(now: DateTime(2026, 11, 30)),
        BudgetLimitLockReason.pastFirstWeek,
      );
    });
  });
}
