import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data/domain/repositories/auth/cc_auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

@lazySingleton
class LogoutUseCase {
  final CcAuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<Unit, CcFailure>> call() {
    return _repository.signOut();
  }
}
