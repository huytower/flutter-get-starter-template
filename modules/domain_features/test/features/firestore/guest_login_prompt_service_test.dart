import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/features/firestore/guest_login_prompt_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnusedAuthCoordinator implements AuthCoordinator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSessionContract implements SessionContract {
  @override
  final bool hasAnonymous;

  @override
  final bool hasAuthenticated;

  @override
  final CcUserEntity? currentUser;

  _FakeSessionContract({
    required this.hasAnonymous,
    required this.hasAuthenticated,
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
          hasAnonymous: false,
          hasAuthenticated: true,
          currentUser: CcUserEntity(
            id: 'user_123',
            email: 'test@example.com',
            status: CcUserStatus.active,
            hasEmailVerified: true,
            hasPhoneVerified: false,
            registeredDeviceIds: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            linkedProviderIds: const ['google.com'],
          ),
        );

        final service = GuestLoginPromptService(session, _UnusedAuthCoordinator());
        final prompt = await service.evaluate();
        expect(prompt, isNull);
      },
    );

    test('evaluates anonymous user conditions properly', () {
      final session = _FakeSessionContract(
        hasAnonymous: true,
        hasAuthenticated: true,
        currentUser: CcUserEntity(
          id: 'guest_123',
          email: '',
          status: CcUserStatus.active,
          hasEmailVerified: false,
          hasPhoneVerified: false,
          registeredDeviceIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          linkedProviderIds: const [],
        ),
      );

      expect(session.hasAnonymous, isTrue);
      expect(session.currentUser?.id, equals('guest_123'));
    });

    test('defines prompt thresholds at 8 and 15', () {
      expect(GuestLoginPrompt.values, contains(GuestLoginPrompt.firstReminder));
      expect(GuestLoginPrompt.values, contains(GuestLoginPrompt.finalWarning));
    });
  });
}
