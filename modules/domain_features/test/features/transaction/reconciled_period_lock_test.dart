import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/services/reconciled_period_lock.dart';
import 'package:domain_features/features/transaction/domain/usecases/delete_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

class _Reconciliations implements ReconciliationRepository {
  _Reconciliations(this.latestDate);

  final DateTime? latestDate;

  @override
  Future<Result<ReconciliationEntity?, CcFailure>> getLatest() async => Success(
    latestDate == null
        ? null
        : ReconciliationEntity(
            id: 'r1',
            year: 2026,
            week: 48,
            systemTotal: 0,
            actualTotal: 0,
            difference: 0,
            allocations: const [],
            adjustmentTransactionIds: const [],
            date: latestDate!,
          ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  final List<String> deleted = [];

  @override
  Future<Result<void, CcFailure>> deleteTransaction(String id) async {
    deleted.add(id);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionEntity _tx(DateTime date) => TransactionEntity(
  id: 't1',
  type: TransactionType.expense,
  amount: 50000,
  category: 'Food',
  date: date,
  walletId: 'cash',
);

void main() {
  final reconciledAt = DateTime(2026, 11, 22, 20, 30);

  group('ReconciledPeriodLock.hasLocked', () {
    test('nothing reconciled: nothing is locked', () {
      expect(ReconciledPeriodLock.hasLocked(_tx(DateTime(2020)), null), false);
    });

    test('dated at or before the reconciliation: locked', () {
      final before = _tx(reconciledAt.subtract(const Duration(minutes: 1)));
      expect(ReconciledPeriodLock.hasLocked(before, reconciledAt), true);
      expect(
        ReconciledPeriodLock.hasLocked(_tx(reconciledAt), reconciledAt),
        true,
      );
    });

    test('dated after the reconciliation (same day too): editable', () {
      final after = _tx(reconciledAt.add(const Duration(minutes: 1)));
      expect(ReconciledPeriodLock.hasLocked(after, reconciledAt), false);
    });
  });

  group('DeleteTransactionUseCase', () {
    test('refuses a reconciled transaction and deletes nothing', () async {
      final transactions = _Transactions();
      final useCase = DeleteTransactionUseCase(
        transactions,
        ReconciledPeriodLock(_Reconciliations(reconciledAt)),
      );

      final result = await useCase(_tx(DateTime(2026, 11, 20)));

      expect(
        result.tryGetError()?.message,
        PrjLocaleKeys.transaction_validation_reconciled,
      );
      expect(transactions.deleted, isEmpty);
    });

    test('deletes an unreconciled transaction', () async {
      final transactions = _Transactions();
      final useCase = DeleteTransactionUseCase(
        transactions,
        ReconciledPeriodLock(_Reconciliations(reconciledAt)),
      );

      final result = await useCase(_tx(DateTime(2026, 11, 23)));

      expect(result.isSuccess(), true);
      expect(transactions.deleted, ['t1']);
    });
  });
}
