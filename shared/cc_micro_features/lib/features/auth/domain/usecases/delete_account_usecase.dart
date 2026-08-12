import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class DeleteAccountUseCase {
  final FirebaseAuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<Result<Unit, CcFailure>> call() {
    return _repository.deleteAccount();
  }
}
