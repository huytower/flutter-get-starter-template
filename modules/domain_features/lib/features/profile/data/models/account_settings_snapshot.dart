import 'dart:convert';
import 'dart:math' as math;

import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';

/// The profile settings that belong to an account rather than to the device.
///
/// They follow the user to every device through Firestore
/// (`users/{uid}/profile/settings`) and are cleared on this device whenever
/// another account (or a guest) takes it over. Device preferences — theme,
/// reminders, tutorial and first-launch stamps, AI consent, the detected
/// region — are not part of it.
class AccountSettingsSnapshot {
  const AccountSettingsSnapshot._(this._values);

  /// Reads the account fields from [storage].
  factory AccountSettingsSnapshot.fromStorage(PrjAppStorage storage) =>
      AccountSettingsSnapshot._({
        _auditDay: storage.weeklyAuditDayIndex,
        _auditDayChangedAt: storage.weeklyAuditDayChangedAt?.toIso8601String(),
        _currency: storage.currencyCode,
        _currencySource: storage.currencySelectionSource,
        _birthYear: storage.birthYear,
        _levelAnchor: storage.levelFeatureAnchorAt?.toIso8601String(),
        _vip: storage.hasVip,
        _highestLevel: storage.highestUserLevelReached,
        _ebookViewed: storage.hasViewedEmergencyFundEbook,
        _customizedCategories: storage.hasCustomizedCategories,
        _guidelineTasks: storage.completedGuidelineTaskIds,
      });

  /// Reads the account fields from a Firestore document or a stored copy.
  /// Unknown keys (sync metadata) are ignored.
  factory AccountSettingsSnapshot.fromJson(Map<String, dynamic> json) =>
      AccountSettingsSnapshot._({for (final key in _keys) key: json[key]});

  /// Decodes [encoded] (from [encode]); null when absent or unreadable.
  static AccountSettingsSnapshot? decode(String? encoded) {
    if (encoded == null) return null;
    try {
      return AccountSettingsSnapshot.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static const _auditDay = 'weeklyAuditDayIndex';
  static const _auditDayChangedAt = 'weeklyAuditDayChangedAt';
  static const _currency = 'currencyCode';
  static const _currencySource = 'currencySelectionSource';
  static const _birthYear = 'birthYear';
  static const _levelAnchor = 'levelFeatureAnchorAt';
  static const _vip = 'hasVip';
  static const _highestLevel = 'highestUserLevelReached';
  static const _ebookViewed = 'hasViewedEmergencyFundEbook';
  static const _customizedCategories = 'hasCustomizedCategories';
  static const _guidelineTasks = 'completedGuidelineTaskIds';

  static const List<String> _keys = [
    _auditDay,
    _auditDayChangedAt,
    _currency,
    _currencySource,
    _birthYear,
    _levelAnchor,
    _vip,
    _highestLevel,
    _ebookViewed,
    _customizedCategories,
    _guidelineTasks,
  ];

  final Map<String, Object?> _values;

  String? get currencyCode => _values[_currency] as String?;

  bool get hasLevelAnchor => _values[_levelAnchor] != null;

  Map<String, Object?> toJson() => Map.unmodifiable(_values);

  String encode() => jsonEncode(_values);

  bool sameAs(AccountSettingsSnapshot? other) =>
      other != null && encode() == other.encode();

  /// Three-way merge of this (local) snapshot with [remote].
  ///
  /// A field changed locally since [base] (the last copy both sides agreed
  /// on) keeps the local value; every other field takes the remote one. With
  /// no [base] the device has never synced this account, so the cloud wins.
  /// The highest level reached is the larger of the two either way: a level
  /// never goes down.
  AccountSettingsSnapshot mergeWith({
    required AccountSettingsSnapshot remote,
    AccountSettingsSnapshot? base,
  }) {
    final merged = <String, Object?>{
      for (final key in _keys)
        key: base != null && !_sameValue(_values[key], base._values[key])
            ? _values[key]
            : remote._values[key],
    };
    merged[_highestLevel] = math.max(
      _level(_values[_highestLevel]),
      _level(remote._values[_highestLevel]),
    );
    return AccountSettingsSnapshot._(merged);
  }

  /// Writes the account fields into [storage] (the caller saves it).
  void applyTo(PrjAppStorage storage) {
    storage
      ..weeklyAuditDayIndex = (_values[_auditDay] as num?)?.toInt()
      ..weeklyAuditDayChangedAt = _date(_values[_auditDayChangedAt])
      ..currencyCode = _values[_currency] as String? ?? storage.currencyCode
      ..currencySelectionSource = _values[_currencySource] as String?
      ..birthYear = (_values[_birthYear] as num?)?.toInt()
      ..levelFeatureAnchorAt = _date(_values[_levelAnchor])
      ..hasVip = _values[_vip] as bool?
      ..highestUserLevelReached = (_values[_highestLevel] as num?)?.toInt()
      ..hasViewedEmergencyFundEbook = _values[_ebookViewed] as bool?
      ..hasCustomizedCategories = _values[_customizedCategories] as bool?
      ..completedGuidelineTaskIds = (_values[_guidelineTasks] as List?)
          ?.map((e) => e.toString())
          .toList();
  }

  /// Puts [storage]'s account fields back to a brand-new account's state
  /// (the caller saves it). Level progress counts from [now]. The currency
  /// stays: it is the device's best guess for the next account's book.
  ///
  /// Paid VIP is cleared too. It is not part of the synced snapshot (it will
  /// come from the store's purchase check for the signed-in account), but it
  /// belongs to the account that bought it, never to the device.
  static void clearIn(PrjAppStorage storage, {required DateTime now}) {
    storage
      ..weeklyAuditDayIndex = null
      ..weeklyAuditDayChangedAt = null
      ..birthYear = null
      ..levelFeatureAnchorAt = now
      ..hasVip = null
      ..hasPaidVip = null
      ..highestUserLevelReached = null
      ..hasViewedEmergencyFundEbook = null
      ..hasCustomizedCategories = null
      ..completedGuidelineTaskIds = null;
  }

  static bool _sameValue(Object? a, Object? b) =>
      jsonEncode(a) == jsonEncode(b);

  static int _level(Object? value) => (value as num?)?.toInt() ?? 1;

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
