import 'package:cc_sdk_data/export_cc_sdk_data.dart';
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
