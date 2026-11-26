import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// The free Profile switch and paid VIP are stored apart; VIP access reads
/// both, so hiding the switch later needs no data migration.
void main() {
  test('no VIP by default', () {
    const settings = ProfileSettingsEntity();
    expect(settings.hasVipSwitch, isFalse);
    expect(settings.hasPaidVip, isFalse);
    expect(settings.hasVipAccess, isFalse);
  });

  test('the free switch grants VIP access but is not paid VIP', () {
    final settings = const ProfileSettingsEntity().copyWith(hasVipSwitch: true);
    expect(settings.hasVipAccess, isTrue);
    expect(settings.hasPaidVip, isFalse);
  });

  test('paid VIP grants VIP access with the switch off', () {
    const settings = ProfileSettingsEntity(hasPaidVip: true);
    expect(settings.hasVipSwitch, isFalse);
    expect(settings.hasVipAccess, isTrue);
  });

  test('turning the switch off keeps paid VIP', () {
    final settings = const ProfileSettingsEntity(
      hasVipSwitch: true,
      hasPaidVip: true,
    ).copyWith(hasVipSwitch: false);
    expect(settings.hasVipAccess, isTrue);
  });
}
