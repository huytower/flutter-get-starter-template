import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class GetCurrentUserUseCase {
  final FirebaseAuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<CcUserEntity?, CcFailure>> call() {
    return _repository.getCurrentUser();
  }
}
