import 'dart:async';

import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../../../../core/constant/currency_catalog.dart';
import '../../../../../core/constant/currency_constants.dart';
import '../../../../../core/migration/financial_schema_migration.dart';
import '../../../domain/entities/profile_settings_entity.dart';

typedef GpsCurrencyDetector =
    Future<({String currencyCode, String? countryCode})> Function();

@lazySingleton
class ProfileLocalDataSource {
  ProfileLocalDataSource()
    : _detectFromGps =
          CurrencyCatalog.detectSuggestedCurrencyFromGpsWithDetails,
      _gpsTimeout = gpsDetectionTimeout;

  @visibleForTesting
  ProfileLocalDataSource.withGpsDetector(
    this._detectFromGps, {
    Duration timeout = gpsDetectionTimeout,
  }) : _gpsTimeout = timeout;

  static const Duration gpsDetectionTimeout = Duration(seconds: 2);

  final GpsCurrencyDetector _detectFromGps;
  final Duration _gpsTimeout;

  Future<ProfileSettingsEntity> getSettings() async {
    final s = CcAppStorage.instance;

    // Run versioned migration to annotate existing financial records with currencyCode (default VND)
    await FinancialSchema.runMigrationIfNeeded();

    // Stamp the user-level feature anchor once, the first time settings are
    // read after this feature shipped. Pre-existing reconciliation/budget
    // data must not count toward level progress, so anything dated before
    // this anchor is excluded by the level-computation use case.
    if (s.levelFeatureAnchorAt == null) {
      s.levelFeatureAnchorAt = DateTime.now();
      await s.save();
    }

    // Stamp the first-launch anchor once, the first time settings are ever
    // read on this install. Anchors the "2 weeks after install" Cloud-backup
    // reminder (see CheckCloudBackupReminderUseCase).
    if (s.firstLaunchAt == null) {
      s.firstLaunchAt = DateTime.now();
      await s.save();
    }

    if (s.currencyCode == null) {
      final fallback = CurrencyCatalog.detectSuggestedCurrencyWithDetails();
      s.currencyCode = CurrencyConstants.validateCurrencyCode(
        fallback.currencyCode,
      );
      s.currencyDetectionCountryCode = fallback.countryCode;
      s.currencySelectionSource = CurrencySelectionSources.detected;
      await s.save();
      '[ProfileLocalDataSource] First launch detected. Locale currency=${s.currencyCode} saved | refining via GPS in background'
          .Log('ProfileLocalDataSource');
      unawaited(_refineCurrencyFromGps());
    } else {
      // Validate existing currency code and source
      final validatedCurrencyCode = CurrencyConstants.validateCurrencyCode(
        s.currencyCode,
      );
      final validatedSource = CurrencySelectionSources.validate(
        s.currencySelectionSource,
      );
      if (s.currencyCode != validatedCurrencyCode ||
          s.currencySelectionSource != validatedSource) {
        s.currencyCode = validatedCurrencyCode;
        s.currencySelectionSource = validatedSource;
        await s.save();
      }
    }

    // Don't default isDarkMode to false - keep it null if not set
    // This allows the system theme to be used as default
    return ProfileSettingsEntity(
      reminderEnabled: s.reminderEnabled ?? false,
      weeklyAuditDayIndex: s.weeklyAuditDayIndex ?? 6,
      currencyCode: s.currencyCode ?? CurrencyConstants.defaultCurrencyCode,
      currencySelectionSource: s.currencySelectionSource,
      currencyDetectionCountryCode: s.currencyDetectionCountryCode,
      birthYear: s.birthYear,
      isDarkMode: s.isDarkMode,
      weeklyAuditDayChangedAt: s.weeklyAuditDayChangedAt,
      levelFeatureAnchorAt: s.levelFeatureAnchorAt,
      isVip: s.isVip ?? CcFeatureFlags.isVipModeEnabled,
      highestUserLevelReached: s.highestUserLevelReached ?? 1,
      firstLaunchAt: s.firstLaunchAt,
      cloudBackupReminderSentAt: s.cloudBackupReminderSentAt,
      hasViewedEmergencyFundEbook: s.hasViewedEmergencyFundEbook ?? false,
      hasSeenTutorial: s.hasSeenTutorial ?? false,
      isHeaderFlipped: s.isProfileHeaderFlipped ?? false,
      hasCustomizedCategories: s.hasCustomizedCategories ?? false,
      completedGuidelineTaskIds: s.completedGuidelineTaskIds ?? const [],
    );
  }

  Future<void> _refineCurrencyFromGps() async {
    try {
      final suggestion = await _detectFromGps().timeout(_gpsTimeout);
      final s = CcAppStorage.instance;
      if (s.currencySelectionSource != CurrencySelectionSources.detected) {
        return;
      }

      final code = CurrencyConstants.validateCurrencyCode(
        suggestion.currencyCode,
      );
      final currencyChanged = code != s.currencyCode;
      if (!currencyChanged &&
          suggestion.countryCode == s.currencyDetectionCountryCode) {
        return;
      }

      s.currencyCode = code;
      s.currencyDetectionCountryCode = suggestion.countryCode;
      await s.save();
      '[ProfileLocalDataSource] GPS refined currency: currencyCode=$code, countryCode=${suggestion.countryCode}'
          .Log('ProfileLocalDataSource');
      if (currencyChanged) CurrencyConstants.onCurrencyChanged.value++;
    } on TimeoutException {
      '[ProfileLocalDataSource] GPS currency detection timed out after ${_gpsTimeout.inMilliseconds}ms | keeping locale currency'
          .Log('ProfileLocalDataSource');
    } catch (e) {
      '[ProfileLocalDataSource] GPS currency detection failed | keeping locale currency | $e'
          .Log('ProfileLocalDataSource');
    }
  }

  Future<void> saveSettings(ProfileSettingsEntity entity) async {
    final s = CcAppStorage.instance;
    s.reminderEnabled = entity.reminderEnabled;
    s.weeklyAuditDayIndex = entity.weeklyAuditDayIndex;
    s.currencyCode = CurrencyConstants.validateCurrencyCode(
      entity.currencyCode,
    );
    s.currencySelectionSource = CurrencySelectionSources.validate(
      entity.currencySelectionSource,
    );
    s.currencyDetectionCountryCode = entity.currencyDetectionCountryCode;
    s.birthYear = entity.birthYear;
    s.isDarkMode = entity.isDarkMode;
    s.weeklyAuditDayChangedAt = entity.weeklyAuditDayChangedAt;
    s.levelFeatureAnchorAt = entity.levelFeatureAnchorAt;
    s.isVip = entity.isVip;
    s.highestUserLevelReached = entity.highestUserLevelReached;
    s.firstLaunchAt = entity.firstLaunchAt;
    s.cloudBackupReminderSentAt = entity.cloudBackupReminderSentAt;
    s.hasViewedEmergencyFundEbook = entity.hasViewedEmergencyFundEbook;
    s.hasSeenTutorial = entity.hasSeenTutorial;
    s.isProfileHeaderFlipped = entity.isHeaderFlipped;
    s.hasCustomizedCategories = entity.hasCustomizedCategories;
    s.completedGuidelineTaskIds = entity.completedGuidelineTaskIds;
    await s.save();
  }
}
