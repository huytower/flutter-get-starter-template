import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:domain_features/features/transaction/domain/services/reconciled_period_lock.dart';
import 'package:multiple_result/multiple_result.dart';

/// A reconciliation history with nothing reconciled yet.
class NoReconciliations implements ReconciliationRepository {
  @override
  Future<Result<ReconciliationEntity?, CcFailure>> getLatest() async =>
      const Success(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [ReconciledPeriodLock] that locks nothing.
ReconciledPeriodLock noReconciliationLock() =>
    ReconciledPeriodLock(NoReconciliations());

/// A reconciliation history whose latest reconciliation was confirmed [at].
class ReconciledAt implements ReconciliationRepository {
  ReconciledAt(this.at);

  final DateTime at;

  @override
  Future<Result<ReconciliationEntity?, CcFailure>> getLatest() async => Success(
    ReconciliationEntity(
      id: 'r-latest',
      year: at.year,
      week: 1,
      systemTotal: 0,
      actualTotal: 0,
      difference: 0,
      allocations: const [],
      adjustmentTransactionIds: const [],
      date: at,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [ReconciledPeriodLock] with the books closed up to [at].
ReconciledPeriodLock reconciliationLockAt(DateTime at) =>
    ReconciledPeriodLock(ReconciledAt(at));
