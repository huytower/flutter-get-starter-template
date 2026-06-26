import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class LogoutUseCase {
  final FirebaseAuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<Unit, CcFailure>> call() {
    return _repository.signOut();
  }
}
