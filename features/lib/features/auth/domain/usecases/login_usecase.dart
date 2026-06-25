import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data/domain/repositories/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call(String email, String password) {
    return _repository.signInWithEmail(email, password);
  }
}
