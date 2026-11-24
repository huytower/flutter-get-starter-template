import 'package:app_config/data/converters/domain_user_entity_converter.dart';
import 'package:app_config/domain/entities/auth/domain_user_entity.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = DomainUserEntityConverter();
  final created = DateTime.utc(2026, 1, 2, 3, 4, 5);

  test('round-trips every field through JSON', () {
    final user = DomainUserEntity(
      id: 'u1',
      email: 'a@example.com',
      phoneNumber: '+10000001',
      status: CcUserStatus.values.last,
      firstName: 'Ann',
      hasEmailVerified: true,
      hasPhoneVerified: false,
      registeredDeviceIds: const ['d1', 'd2'],
      createdAt: created,
      updatedAt: created,
      lastActiveAt: created,
    );

    final back = converter.fromJson(converter.toJson(user))!;

    expect(back.id, 'u1');
    expect(back.phoneNumber, '+10000001');
    expect(back.status, CcUserStatus.values.last);
    expect(back.registeredDeviceIds, ['d1', 'd2']);
    expect(back.lastActiveAt, created);
  });

  test('missing or unknown status and flags fall back to safe defaults', () {
    final user = converter.fromJson({
      'id': 'u2',
      'email': '',
      'status': 'no-such-status',
      'createdAt': created.toIso8601String(),
      'updatedAt': created.toIso8601String(),
    })!;

    expect(user.status, CcUserStatus.active);
    expect(user.hasEmailVerified, isFalse);
    expect(user.registeredDeviceIds, isEmpty);
    expect(user.lastActiveAt, isNull);
  });

  test('null in, null out', () {
    expect(converter.fromJson(null), isNull);
    expect(converter.toJson(null), isNull);
  });
}
