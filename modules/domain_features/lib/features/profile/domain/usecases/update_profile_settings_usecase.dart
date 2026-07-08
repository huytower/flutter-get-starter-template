import 'package:injectable/injectable.dart';

import '../entities/profile_settings_entity.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UpdateProfileSettingsUseCase {
  UpdateProfileSettingsUseCase(this._repo);

  final ProfileRepository _repo;

  Future<void> call(ProfileSettingsEntity settings) => _repo.saveSettings(settings);
}
