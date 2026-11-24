import 'dart:async';

import 'package:app_config/core/config/app/prj_feature_flags.dart';
import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../../../../core/constant/currency_constants.dart';
import '../../../../../core/migration/financial_schema_migration.dart';

typedef GpsCurrencyDetector =
    Future<({String currencyCode, String? countryCode})> Function();

@LazySingleton()
class ProfileLocalDataSource {
  ProfileLocalDataSource(this._location)
    : _detectFromGps = (() =>
          CurrencyCatalog.detectSuggestedCurrencyFromGpsWithDetails(_location)),
      _gpsTimeout = gpsDetectionTimeout {
    _location.lastPosition.addListener(_onGpsPositionUpdated);
  }

  @visibleForTesting
  ProfileLocalDataSource.withGpsDetector(
    this._detectFromGps, {
    Duration timeout = gpsDetectionTimeout,
    CcLocationService? location,
  }) : _gpsTimeout = timeout,
       _location = location ?? CcNoopLocationService() {
    _location.lastPosition.addListener(_onGpsPositionUpdated);
  }

  static const Duration gpsDetectionTimeout = Duration(seconds: 15);

  final GpsCurrencyDetector _detectFromGps;
  final CcLocationService _location;

  final Duration _gpsTimeout;

  Future<ProfileSettingsEntity> getSettings() async {
    final storage = PrjAppStorage.instance;

    // Run versioned migration to annotate existing financial records with currencyCode (default VND)
    await FinancialSchemaMigration.runMigrationIfNeeded();

    // Stamp the user-level feature anchor once, the first time settings are
    // read after this feature shipped. Pre-existing reconciliation/budget
    // data must not count toward level progress, so anything dated before
    // this anchor is excluded by the level-computation use case.
    if (storage.levelFeatureAnchorAt == null) {
      storage.levelFeatureAnchorAt = DateTime.now();
      await storage.save();
    }

    // Stamp the first-launch anchor once, the first time settings are ever
    // read on this install. Anchors the "2 weeks after install" Cloud-backup
    // reminder (see CheckCloudBackupReminderUseCase).
    if (storage.firstLaunchAt == null) {
      storage.firstLaunchAt = DateTime.now();
      await storage.save();
    }

    if (storage.currencyCode == null) {
      final fallback = CurrencyCatalog.detectSuggestedCurrencyWithDetails();
      storage.currencyCode = CurrencyConstants.validateCurrencyCode(
        fallback.currencyCode,
      );
      storage.currencyDetectionCountryCode = fallback.countryCode;
      storage.currencySelectionSource = CurrencySelectionSources.detected;
      await storage.save();
      unawaited(_refineCurrencyFromGps());
    } else {
      // Validate existing currency code and source
      final validatedCurrencyCode = CurrencyConstants.validateCurrencyCode(
        storage.currencyCode,
      );
      final validatedSource = CurrencySelectionSources.validate(
        storage.currencySelectionSource,
      );
      if (storage.currencyCode != validatedCurrencyCode ||
          storage.currencySelectionSource != validatedSource) {
        storage.currencyCode = validatedCurrencyCode;
        storage.currencySelectionSource = validatedSource;
        await storage.save();
      }

      // If currency was auto-detected (not manually selected by user), refine via GPS in background
      if (storage.currencySelectionSource == CurrencySelectionSources.detected) {
        unawaited(_refineCurrencyFromGps());
      }
    }

    // Don't default isDarkMode to false - keep it null if not set
    // This allows the system theme to be used as default
    return ProfileSettingsEntity(
      reminderEnabled: storage.reminderEnabled ?? false,
      weeklyAuditDayIndex: storage.weeklyAuditDayIndex ?? 6,
      currencyCode: storage.currencyCode ?? CurrencyConstants.defaultCurrencyCode,
      currencySelectionSource: storage.currencySelectionSource,
      currencyDetectionCountryCode: storage.currencyDetectionCountryCode,
      birthYear: storage.birthYear,
      hasDarkMode: storage.hasDarkMode,
      weeklyAuditDayChangedAt: storage.weeklyAuditDayChangedAt,
      levelFeatureAnchorAt: storage.levelFeatureAnchorAt,
      hasVip: storage.hasVip ?? PrjFeatureFlags.hasVipModeEnabled,
      highestUserLevelReached: storage.highestUserLevelReached ?? 1,
      firstLaunchAt: storage.firstLaunchAt,
      cloudBackupReminderSentAt: storage.cloudBackupReminderSentAt,
      hasViewedEmergencyFundEbook: storage.hasViewedEmergencyFundEbook ?? false,
      hasSeenTutorial: storage.hasSeenTutorial ?? false,
      hasHeaderFlipped: storage.hasProfileHeaderFlipped ?? false,
      hasCustomizedCategories: storage.hasCustomizedCategories ?? false,
      completedGuidelineTaskIds: storage.completedGuidelineTaskIds ?? const [],
    );
  }

  bool _hasRefinedGps = false;
  Future<void>? _refineCurrencyFuture;

  Future<void> _refineCurrencyFromGps() {
    if (_hasRefinedGps) {
      return _refineCurrencyFuture ?? Future.value();
    }
    _hasRefinedGps = true;
    _refineCurrencyFuture = _doRefineCurrencyFromGps();
    return _refineCurrencyFuture!;
  }

  Future<void> _doRefineCurrencyFromGps() async {
    final storage = PrjAppStorage.instance;
    try {
      final suggestion = await _detectFromGps().timeout(_gpsTimeout);

      if (storage.currencySelectionSource != CurrencySelectionSources.detected) {
        return;
      }

      final code = CurrencyConstants.validateCurrencyCode(
        suggestion.currencyCode,
      );
      final currencyChanged = code != storage.currencyCode;

      if (!currencyChanged &&
          suggestion.countryCode == storage.currencyDetectionCountryCode) {
        return;
      }

      storage.currencyCode = code;
      storage.currencyDetectionCountryCode = suggestion.countryCode;
      await storage.save();

      if (currencyChanged) {
        CurrencyConstants.onCurrencyChanged.value++;
      }
      CurrencyConstants.onRegionalSettingsChanged.value++;
    } on TimeoutException catch (e) {
      'Regional settings save timed out: $e'.Log('ProfileLocalDataSource');
    } catch (_) {}
  }

  Future<void> _onGpsPositionUpdated() async {
    final pos = _location.lastPosition.value;
    if (pos == null) return;

    final storage = PrjAppStorage.instance;
    if (storage.currencySelectionSource != CurrencySelectionSources.detected) {
      return;
    }

    try {
      final isoCountryCode = await _location.countryCodeAt(pos);
      if (isoCountryCode == null ||
          !CurrencyCatalog.countryCodeToCurrency.containsKey(isoCountryCode)) {
        return;
      }

      final currency = CurrencyCatalog.countryCodeToCurrency[isoCountryCode]!;
      final code = CurrencyConstants.validateCurrencyCode(currency);
      final currencyChanged = code != storage.currencyCode;

      if (!currencyChanged &&
          isoCountryCode == storage.currencyDetectionCountryCode) {
        return;
      }

      storage.currencyCode = code;
      storage.currencyDetectionCountryCode = isoCountryCode;
      await storage.save();

      if (currencyChanged) {
        CurrencyConstants.onCurrencyChanged.value++;
      }
      CurrencyConstants.onRegionalSettingsChanged.value++;
    } catch (_) {}
  }

  Future<void> saveSettings(ProfileSettingsEntity entity) async {
    final storage = PrjAppStorage.instance;
    storage.reminderEnabled = entity.reminderEnabled;
    storage.weeklyAuditDayIndex = entity.weeklyAuditDayIndex;
    storage.currencyCode = CurrencyConstants.validateCurrencyCode(
      entity.currencyCode,
    );
    storage.currencySelectionSource = CurrencySelectionSources.validate(
      entity.currencySelectionSource,
    );
    storage.currencyDetectionCountryCode = entity.currencyDetectionCountryCode;
    storage.birthYear = entity.birthYear;
    storage.hasDarkMode = entity.hasDarkMode;
    storage.weeklyAuditDayChangedAt = entity.weeklyAuditDayChangedAt;
    storage.levelFeatureAnchorAt = entity.levelFeatureAnchorAt;
    storage.hasVip = entity.hasVip;
    storage.highestUserLevelReached = entity.highestUserLevelReached;
    storage.firstLaunchAt = entity.firstLaunchAt;
    storage.cloudBackupReminderSentAt = entity.cloudBackupReminderSentAt;
    storage.hasViewedEmergencyFundEbook = entity.hasViewedEmergencyFundEbook;
    storage.hasSeenTutorial = entity.hasSeenTutorial;
    storage.hasProfileHeaderFlipped = entity.hasHeaderFlipped;
    storage.hasCustomizedCategories = entity.hasCustomizedCategories;
    storage.completedGuidelineTaskIds = entity.completedGuidelineTaskIds;
    await storage.save();
  }
}
