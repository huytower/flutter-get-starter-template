import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class LinkWithAppleUseCase {
  final FirebaseAuthRepository _repository;

  LinkWithAppleUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call() {
    return _repository.linkWithApple();
  }
}
