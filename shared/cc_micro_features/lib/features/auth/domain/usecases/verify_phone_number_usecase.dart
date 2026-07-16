import 'package:injectable/injectable.dart';

import '../phone_auth_status.dart';
import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class VerifyPhoneNumberUseCase {
  final FirebaseAuthRepository _repository;

  VerifyPhoneNumberUseCase(this._repository);

  Stream<PhoneAuthStatus> call({required String phoneNumber}) {
    return _repository.verifyPhoneNumber(phoneNumber: phoneNumber);
  }
}
