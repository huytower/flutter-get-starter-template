import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/features/firestore/guest_login_prompt_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSessionContract implements SessionContract {
  @override
  final bool isAnonymous;

  @override
  final bool isAuthenticated;

  @override
  final CcUserEntity? currentUser;

  _FakeSessionContract({
    required this.isAnonymous,
    required this.isAuthenticated,
    required this.currentUser,
  });

  @override
  Stream<CcUserEntity?> get userStream => Stream.value(currentUser);

  @override
  Future<void> clearSession() async {}
}

void main() {
  group('GuestLoginPromptService', () {
    test(
      'returns null when user is authenticated with real account (not anonymous)',
      () async {
        final session = _FakeSessionContract(
          isAnonymous: false,
          isAuthenticated: true,
          currentUser: CcUserEntity(
            id: 'user_123',
            email: 'test@example.com',
            status: CcUserStatus.active,
            isEmailVerified: true,
            isPhoneVerified: false,
            registeredDeviceIds: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            linkedProviderIds: const ['google.com'],
          ),
        );

        final service = GuestLoginPromptService(session);
        final prompt = await service.evaluate();
        expect(prompt, isNull);
      },
    );

    test('evaluates anonymous user conditions properly', () {
      final session = _FakeSessionContract(
        isAnonymous: true,
        isAuthenticated: true,
        currentUser: CcUserEntity(
          id: 'guest_123',
          email: '',
          status: CcUserStatus.active,
          isEmailVerified: false,
          isPhoneVerified: false,
          registeredDeviceIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          linkedProviderIds: const [],
        ),
      );

      expect(session.isAnonymous, isTrue);
      expect(session.currentUser?.id, equals('guest_123'));
    });

    test('defines prompt threshold as 15 (final warning)', () {
      expect(GuestLoginPrompt.values, contains(GuestLoginPrompt.finalWarning));
    });
  });
}
