import 'package:cc_sdk_data/domain/entities/cc_user_entity.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class LoginAnonymouslyUseCase {
  final FirebaseAuthRepository _repository;

  LoginAnonymouslyUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call() {
    return _repository.signInAnonymously();
  }
}
