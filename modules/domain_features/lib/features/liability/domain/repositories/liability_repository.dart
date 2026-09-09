import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/liability_entity.dart';

abstract class LiabilityRepository {
  Future<Result<List<LiabilityEntity>, CcFailure>> getLiabilities();

  Future<Result<LiabilityEntity, CcFailure>> getLiability(String id);

  Future<Result<void, CcFailure>> createLiability(LiabilityEntity liability);

  Future<Result<void, CcFailure>> updateLiability(LiabilityEntity liability);

  /// Only used to roll back a liability when its initiating transaction write
  /// fails (see `CreateLiabilityUseCase`) — this feature has no edit/delete UI.
  Future<Result<void, CcFailure>> deleteLiability(String id);
}


