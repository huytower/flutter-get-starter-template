import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data/domain/repositories/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

@lazySingleton
class SignInWithPhoneNumberUseCase {
  final AuthRepository _repository;

  SignInWithPhoneNumberUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.signInWithPhoneNumber(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
