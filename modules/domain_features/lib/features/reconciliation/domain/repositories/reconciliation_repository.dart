import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/reconciliation_entity.dart';

abstract class ReconciliationRepository {
  /// History, newest first.
  Future<Result<List<ReconciliationEntity>, CcFailure>> getReconciliations();

  /// The most recent reconciliation, or null when none exist.
  Future<Result<ReconciliationEntity?, CcFailure>> getLatest();

  Future<Result<void, CcFailure>> saveReconciliation(
    ReconciliationEntity reconciliation,
  );

  Future<Result<void, CcFailure>> deleteReconciliation(String id);
}
