import 'package:data/domain/entities/auth/cc_phone_auth_event.dart';
import 'package:data/domain/repositories/auth/cc_auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class VerifyPhoneNumberUseCase {
  final CcAuthRepository _repository;
  final Logger _logger = Logger(printer: SimplePrinter());

  VerifyPhoneNumberUseCase(this._repository);

  Stream<CcPhoneAuthEvent> call({required String phoneNumber}) {
    _logger.i(
      'VerifyPhoneNumberUseCase: Called with phone number: $phoneNumber',
    );
    return _repository.verifyPhoneNumber(phoneNumber: phoneNumber);
  }
}
