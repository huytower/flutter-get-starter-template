import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/profile_settings_entity.dart';

@lazySingleton
class ProfileLocalDataSource {
  ProfileSettingsEntity getSettings() {
    final s = CcAppStorage.instance;
    return ProfileSettingsEntity(
      reminderEnabled: s.reminderEnabled ?? true,
      weeklyAuditDayIndex: s.weeklyAuditDayIndex ?? 6,
      currencyCode: s.currencyCode ?? 'VND',
      birthYear: s.birthYear,
    );
  }

  Future<void> saveSettings(ProfileSettingsEntity entity) async {
    final s = CcAppStorage.instance;
    s.reminderEnabled = entity.reminderEnabled;
    s.weeklyAuditDayIndex = entity.weeklyAuditDayIndex;
    s.currencyCode = entity.currencyCode;
    s.birthYear = entity.birthYear;
    await s.save();
  }
}
