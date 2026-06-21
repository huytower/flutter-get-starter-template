import 'dart:convert';

import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data/domain/entities/auth/cc_user_entity.dart';
import 'package:data/domain/repositories/auth/cc_auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:multiple_result/multiple_result.dart';

@lazySingleton
class SignInWithPhoneNumberUseCase {
  final CcAuthRepository _repository;
  final Logger _logger = Logger(printer: SimplePrinter());

  SignInWithPhoneNumberUseCase(this._repository);

  Future<Result<CcUserEntity, CcFailure>> call({
    required String verificationId,
    required String smsCode,
  }) async {
    _logger.i(
      'SignInWithPhoneNumberUseCase: Called with verificationId: $verificationId, smsCode: $smsCode',
    );
    final result = await _repository.signInWithPhoneNumber(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final resultStr = result.when(
      (user) => jsonEncode(user.toJson()),
      (failure) => failure.message,
    );
    _logger.i('SignInWithPhoneNumberUseCase: Result: $resultStr');
    return result;
  }
}
