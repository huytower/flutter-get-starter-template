import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/auth_repository.dart';

@lazySingleton
class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  /// See [AuthRepository.deleteAccount] for when [beforeDelete] runs.
  Future<Result<Unit, CcFailure>> call({Future<void> Function()? beforeDelete}) {
    return _repository.deleteAccount(beforeDelete: beforeDelete);
  }
}
