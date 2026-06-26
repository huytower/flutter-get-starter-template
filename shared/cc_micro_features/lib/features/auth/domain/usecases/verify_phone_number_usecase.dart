import 'package:injectable/injectable.dart';

import '../../presentation/bloc/phone_auth_event.dart';
import '../repositories/firebase_auth_repository.dart';

@lazySingleton
class VerifyPhoneNumberUseCase {
  final FirebaseAuthRepository _repository;

  VerifyPhoneNumberUseCase(this._repository);

  Stream<PhoneAuthEvent> call({required String phoneNumber}) {
    return _repository.verifyPhoneNumber(phoneNumber: phoneNumber);
  }
}
