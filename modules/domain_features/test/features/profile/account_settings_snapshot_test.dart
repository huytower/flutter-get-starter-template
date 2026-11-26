import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:domain_features/features/profile/data/models/account_settings_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

PrjAppStorage _storage({
  int? auditDay,
  int? birthYear,
  int? level,
  bool? vip,
  String currency = 'VND',
  List<String>? tasks,
}) => PrjAppStorage(
  weeklyAuditDayIndex: auditDay,
  birthYear: birthYear,
  highestUserLevelReached: level,
  hasVip: vip,
  currencyCode: currency,
  completedGuidelineTaskIds: tasks,
);

AccountSettingsSnapshot _snap(PrjAppStorage s) =>
    AccountSettingsSnapshot.fromStorage(s);

void main() {
  test('never synced on this device: the cloud copy wins', () {
    final local = _snap(_storage(auditDay: 2, birthYear: 1990, level: 1));
    final remote = _snap(_storage(auditDay: 6, birthYear: 1985, level: 3));

    final merged = local.mergeWith(remote: remote);

    expect(merged.toJson()['weeklyAuditDayIndex'], 6);
    expect(merged.toJson()['birthYear'], 1985);
    expect(merged.toJson()['highestUserLevelReached'], 3);
  });

  test('a field changed locally since the last sync keeps the local value', () {
    final base = _snap(_storage(auditDay: 6, birthYear: 1990, level: 2));
    final local = _snap(_storage(auditDay: 3, birthYear: 1990, level: 2));
    final remote = _snap(_storage(auditDay: 6, birthYear: 1992, level: 2));

    final merged = local.mergeWith(remote: remote, base: base);

    expect(merged.toJson()['weeklyAuditDayIndex'], 3, reason: 'local edit');
    expect(merged.toJson()['birthYear'], 1992, reason: 'remote edit');
  });

  test('the highest level never goes down in a merge', () {
    final base = _snap(_storage(level: 2));
    final local = _snap(_storage(level: 3));
    final remote = _snap(_storage(level: 2));

    expect(
      local
          .mergeWith(remote: remote, base: base)
          .toJson()['highestUserLevelReached'],
      3,
    );
    expect(
      remote
          .mergeWith(remote: local, base: base)
          .toJson()['highestUserLevelReached'],
      3,
    );
  });

  test('clearIn resets the account fields but keeps the currency', () {
    final storage = _storage(
      auditDay: 2,
      birthYear: 1990,
      level: 3,
      vip: true,
      currency: 'USD',
      tasks: const ['birth_year'],
    )..hasPaidVip = true;
    final now = DateTime(2026, 11, 26);

    AccountSettingsSnapshot.clearIn(storage, now: now);

    expect(storage.weeklyAuditDayIndex, isNull);
    expect(storage.birthYear, isNull);
    expect(storage.highestUserLevelReached, isNull);
    expect(storage.hasVip, isNull);
    expect(storage.hasPaidVip, isNull, reason: 'paid VIP stays with its buyer');
    expect(storage.completedGuidelineTaskIds, isNull);
    expect(storage.levelFeatureAnchorAt, now);
    expect(storage.currencyCode, 'USD');
  });

  test('applyTo and fromStorage round-trip through JSON', () {
    final source = _storage(
      auditDay: 4,
      birthYear: 1995,
      level: 2,
      vip: false,
      currency: 'JPY',
      tasks: const ['birth_year', 'categories'],
    )..levelFeatureAnchorAt = DateTime(2026, 1, 2);
    final encoded = _snap(source).encode();

    final target = PrjAppStorage();
    AccountSettingsSnapshot.decode(encoded)!.applyTo(target);

    expect(_snap(target).encode(), encoded);
    expect(target.completedGuidelineTaskIds, ['birth_year', 'categories']);
    expect(target.levelFeatureAnchorAt, DateTime(2026, 1, 2));
  });

  test('sync metadata in the Firestore document is ignored', () {
    final fromCloud = AccountSettingsSnapshot.fromJson({
      ..._snap(_storage(auditDay: 1)).toJson(),
      'localId': 'settings',
      'remoteId': 'settings',
      'lastModifiedAt': '2026-11-26T09:00:00',
    });

    expect(fromCloud.sameAs(_snap(_storage(auditDay: 1))), isTrue);
  });

  test('an unreadable stored copy decodes to null', () {
    expect(AccountSettingsSnapshot.decode('not json'), isNull);
    expect(AccountSettingsSnapshot.decode(null), isNull);
  });
}
