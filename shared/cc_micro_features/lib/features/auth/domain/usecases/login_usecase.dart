import 'package:cc_bridge/export_cc_bridge.dart';

import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final FirebaseAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call(String email, String password) {
    return _repository.signInWithEmail(email, password);
  }
}
