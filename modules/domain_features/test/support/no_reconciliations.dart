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
