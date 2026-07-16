import 'package:injectable/injectable.dart';

import '../../domain/entities/profile_settings_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/local/profile_local_datasource.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileLocalDataSource local})
    : _local = local;

  final ProfileLocalDataSource _local;

  @override
  Future<ProfileSettingsEntity> getSettings() async => _local.getSettings();

  @override
  Future<void> saveSettings(ProfileSettingsEntity settings) =>
      _local.saveSettings(settings);
}
