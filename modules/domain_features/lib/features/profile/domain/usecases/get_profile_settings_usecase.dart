import 'package:injectable/injectable.dart';

import '../entities/profile_settings_entity.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class GetProfileSettingsUseCase {
  GetProfileSettingsUseCase(this._repo);

  final ProfileRepository _repo;

  Future<ProfileSettingsEntity> call() => _repo.getSettings();
}
