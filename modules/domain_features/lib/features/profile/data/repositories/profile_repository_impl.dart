import 'package:injectable/injectable.dart';

import '../../../firestore/financial_data_sync_service.dart';
import '../../domain/entities/profile_settings_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/local/profile_local_datasource.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final ProfileLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  @override
  Future<ProfileSettingsEntity> getSettings() async => _local.getSettings();

  /// Saves locally first, then lets the background sync upload the account
  /// settings (level, VIP, guideline, audit day, ...) like any other record.
  @override
  Future<void> saveSettings(ProfileSettingsEntity settings) async {
    await _local.saveSettings(settings);
    _syncService.syncAll();
  }
}
