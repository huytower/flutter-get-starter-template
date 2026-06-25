import 'package:data/domain/entities/auth/domain_phone_auth_event.dart';
import 'package:data/domain/repositories/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VerifyPhoneNumberUseCase {
  final AuthRepository _repository;

  VerifyPhoneNumberUseCase(this._repository);

  Stream<DomainPhoneAuthEvent> call({required String phoneNumber}) {
    return _repository.verifyPhoneNumber(phoneNumber: phoneNumber);
  }
}
