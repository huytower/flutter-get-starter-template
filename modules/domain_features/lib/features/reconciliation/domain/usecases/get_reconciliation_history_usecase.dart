import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/reconciliation_entity.dart';
import '../repositories/reconciliation_repository.dart';

@lazySingleton
class GetReconciliationHistoryUseCase {
  GetReconciliationHistoryUseCase(this._repository);

  final ReconciliationRepository _repository;

  Future<Result<List<ReconciliationEntity>, CcFailure>> call() =>
      _repository.getReconciliations();
}
