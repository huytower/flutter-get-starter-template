import 'package:cc_bridge/export_cc_bridge.dart';

import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/auth_repository.dart';

@lazySingleton
class LoginWithAppleUseCase {
  final AuthRepository _repository;

  LoginWithAppleUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call() {
    return _repository.signInWithApple();
  }
}
