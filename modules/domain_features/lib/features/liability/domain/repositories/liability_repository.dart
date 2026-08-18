import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/liability_entity.dart';

abstract class LiabilityRepository {
  Future<Result<List<LiabilityEntity>, CcFailure>> getLoans();

  Future<Result<LiabilityEntity, CcFailure>> getLoan(String id);

  Future<Result<void, CcFailure>> createLoan(LiabilityEntity loan);

  Future<Result<void, CcFailure>> updateLoan(LiabilityEntity loan);

  /// Only used to roll back a loan when its initiating transaction write
  /// fails (see `CreateLiabilityUseCase`) — this feature has no edit/delete UI.
  Future<Result<void, CcFailure>> deleteLoan(String id);
}


