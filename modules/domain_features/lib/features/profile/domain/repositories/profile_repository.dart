import '../entities/profile_settings_entity.dart';

abstract class ProfileRepository {
  Future<ProfileSettingsEntity> getSettings();
  Future<void> saveSettings(ProfileSettingsEntity settings);
}
