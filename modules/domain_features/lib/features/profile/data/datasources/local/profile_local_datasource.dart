import 'dart:async';

import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:domain_features/features/wallet/data/datasources/local/wallet_local_datasource.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constant/currency_catalog.dart';
import '../../../../../core/constant/currency_constants.dart';
import '../../../../../core/migration/financial_schema_migration.dart';

typedef GpsCurrencyDetector =
    Future<({String currencyCode, String? countryCode})> Function();

@LazySingleton()
class ProfileLocalDataSource {
  ProfileLocalDataSource()
    : _detectFromGps =
          CurrencyCatalog.detectSuggestedCurrencyFromGpsWithDetails,
      _gpsTimeout = gpsDetectionTimeout {
    CcLocationHelper.lastGpsPosition.addListener(_onGpsPositionUpdated);
  }

  @visibleForTesting
  ProfileLocalDataSource.withGpsDetector(
    this._detectFromGps, {
    Duration timeout = gpsDetectionTimeout,
  }) : _gpsTimeout = timeout {
    CcLocationHelper.lastGpsPosition.addListener(_onGpsPositionUpdated);
  }

  static const Duration gpsDetectionTimeout = Duration(seconds: 15);

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

      // If currency was auto-detected (not manually selected by user), refine via GPS in background
      if (s.currencySelectionSource == CurrencySelectionSources.detected) {
        unawaited(_refineCurrencyFromGps());
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

  Future<void>? _refineCurrencyFuture;

  Future<void> _refineCurrencyFromGps() {
    if (_refineCurrencyFuture != null) {
      return _refineCurrencyFuture!;
    }
    _refineCurrencyFuture = _doRefineCurrencyFromGps().whenComplete(() {
      _refineCurrencyFuture = null;
    });
    return _refineCurrencyFuture!;
  }

  Future<void> _doRefineCurrencyFromGps() async {
    final s = CcAppStorage.instance;
    try {
      final suggestion = await _detectFromGps().timeout(_gpsTimeout);

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

      if (currencyChanged) {
        await _updateDefaultWalletsCurrency(code);
        CurrencyConstants.onCurrencyChanged.value++;
      }
      CurrencyConstants.onRegionalSettingsChanged.value++;
    } on TimeoutException catch (e) {
      'Regional settings save timed out: $e'.Log('ProfileLocalDataSource');
    } catch (_) {}
  }

  Future<void> _updateDefaultWalletsCurrency(String newCurrencyCode) async {
    try {
      final walletDataSource = getIt<WalletLocalDataSource>();
      await walletDataSource.updateDefaultWalletsCurrency(newCurrencyCode);
    } catch (_) {}
  }

  Future<void> _onGpsPositionUpdated() async {
    final pos = CcLocationHelper.lastGpsPosition.value;
    if (pos == null) return;

    final s = CcAppStorage.instance;
    if (s.currencySelectionSource != CurrencySelectionSources.detected) {
      return;
    }

    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isEmpty) return;

      final isoCountryCode = placemarks.first.isoCountryCode?.toUpperCase();
      if (isoCountryCode == null ||
          !CurrencyCatalog.countryCodeToCurrency.containsKey(isoCountryCode)) {
        return;
      }

      final currency = CurrencyCatalog.countryCodeToCurrency[isoCountryCode]!;
      final code = CurrencyConstants.validateCurrencyCode(currency);
      final currencyChanged = code != s.currencyCode;

      if (!currencyChanged &&
          isoCountryCode == s.currencyDetectionCountryCode) {
        return;
      }

      s.currencyCode = code;
      s.currencyDetectionCountryCode = isoCountryCode;
      await s.save();

      if (currencyChanged) {
        await _updateDefaultWalletsCurrency(code);
        CurrencyConstants.onCurrencyChanged.value++;
      }
      CurrencyConstants.onRegionalSettingsChanged.value++;
    } catch (_) {}
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
