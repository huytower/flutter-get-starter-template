import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@lazySingleton
class AuthStateChangesUseCase {
  final AuthRepository _repository;

  AuthStateChangesUseCase(this._repository);

  Stream<CcUserEntity?> call() {
    return _repository.authStateChanges();
  }
}
