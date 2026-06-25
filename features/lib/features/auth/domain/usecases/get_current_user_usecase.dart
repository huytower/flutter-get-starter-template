import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data/domain/repositories/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

@lazySingleton
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<CcUserEntity?, CcFailure>> call() {
    return _repository.getCurrentUser();
  }
}
