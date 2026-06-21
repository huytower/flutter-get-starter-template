import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data/domain/entities/auth/cc_user_entity.dart';
import 'package:data/domain/repositories/auth/cc_auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

@lazySingleton
class LoginAnonymouslyUseCase {
  final CcAuthRepository _repository;

  LoginAnonymouslyUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call() {
    return _repository.signInAnonymously();
  }
}
