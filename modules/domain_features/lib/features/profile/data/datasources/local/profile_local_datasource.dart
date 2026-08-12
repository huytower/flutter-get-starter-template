import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/profile_settings_entity.dart';

@lazySingleton
class ProfileLocalDataSource {
  Future<ProfileSettingsEntity> getSettings() async {
    final s = CcAppStorage.instance;

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

    // Don't default isDarkMode to false - keep it null if not set
    // This allows the system theme to be used as default
    return ProfileSettingsEntity(
      reminderEnabled: s.reminderEnabled ?? true,
      weeklyAuditDayIndex: s.weeklyAuditDayIndex ?? 6,
      currencyCode: s.currencyCode ?? 'VND',
      birthYear: s.birthYear,
      isDarkMode: s.isDarkMode,
      weeklyAuditDayChangedAt: s.weeklyAuditDayChangedAt,
      levelFeatureAnchorAt: s.levelFeatureAnchorAt,
      isVip: s.isVip ?? false,
      forceFullAccess: s.forceFullAccess ?? false,
      highestUserLevelReached: s.highestUserLevelReached ?? 1,
      firstLaunchAt: s.firstLaunchAt,
      cloudBackupReminderSentAt: s.cloudBackupReminderSentAt,
      hasViewedEmergencyFundEbook: s.hasViewedEmergencyFundEbook ?? false,
      hasSeenTutorial: s.hasSeenTutorial ?? false,
      isHeaderFlipped: s.isProfileHeaderFlipped ?? false,
      hasCustomizedCategories: s.hasCustomizedCategories ?? false,
    );
  }

  Future<void> saveSettings(ProfileSettingsEntity entity) async {
    final s = CcAppStorage.instance;
    s.reminderEnabled = entity.reminderEnabled;
    s.weeklyAuditDayIndex = entity.weeklyAuditDayIndex;
    s.currencyCode = entity.currencyCode;
    s.birthYear = entity.birthYear;
    s.isDarkMode = entity.isDarkMode;
    s.weeklyAuditDayChangedAt = entity.weeklyAuditDayChangedAt;
    s.levelFeatureAnchorAt = entity.levelFeatureAnchorAt;
    s.isVip = entity.isVip;
    s.forceFullAccess = entity.forceFullAccess;
    s.highestUserLevelReached = entity.highestUserLevelReached;
    s.firstLaunchAt = entity.firstLaunchAt;
    s.cloudBackupReminderSentAt = entity.cloudBackupReminderSentAt;
    s.hasViewedEmergencyFundEbook = entity.hasViewedEmergencyFundEbook;
    s.hasSeenTutorial = entity.hasSeenTutorial;
    s.isProfileHeaderFlipped = entity.isHeaderFlipped;
    s.hasCustomizedCategories = entity.hasCustomizedCategories;
    await s.save();
  }
}
