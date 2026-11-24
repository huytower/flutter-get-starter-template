import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/app_version_entity.dart';
import '../../domain/entities/installed_app_entity.dart';
import '../../domain/repositories/app_update_repository.dart';

@LazySingleton(as: AppUpdateRepository)
class AppUpdateRepositoryImpl implements AppUpdateRepository {
  bool get _hasAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get _hasIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<Result<InstalledAppEntity, CcFailure>> getInstalledApp() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final raw = info.buildNumber.isEmpty
          ? info.version
          : '${info.version}+${info.buildNumber}';
      final version =
          AppVersionEntity.tryParse(raw) ??
          AppVersionEntity.tryParse(info.version);
      if (version == null) {
        return Error(CcDeviceFailure('Unreadable app version "$raw"'));
      }
      return Success(
        InstalledAppEntity(
          version: version,
          packageName: info.packageName,
          hasStoreDistributed: _hasAndroid || _hasIOS,
        ),
      );
    } catch (e) {
      return Error(CcDeviceFailure('Failed to read app version: $e'));
    }
  }

  @override
  Future<Result<Unit, CcFailure>> openStore({
    String? iosAppStoreId,
    String? androidPackageName,
  }) async {
    try {
      final List<Uri> candidates;
      if (_hasIOS) {
        final id = iosAppStoreId?.trim() ?? '';
        if (id.isEmpty) {
          return const Error(CcValidationFailure('Missing App Store id'));
        }
        candidates = [
          Uri.parse('itms-apps://itunes.apple.com/app/id$id'),
          Uri.parse('https://apps.apple.com/app/id$id'),
        ];
      } else if (_hasAndroid) {
        var package = androidPackageName?.trim() ?? '';
        if (package.isEmpty) {
          package = (await PackageInfo.fromPlatform()).packageName;
        }
        candidates = [
          Uri.parse('market://details?id=$package'),
          Uri.parse('https://play.google.com/store/apps/details?id=$package'),
        ];
      } else {
        return const Error(CcDeviceFailure('No app store on this platform'));
      }

      for (final uri in candidates) {
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        ).catchError((_) => false);
        if (opened) return const Success(unit);
      }
      return const Error(CcDeviceFailure('Could not open the app store'));
    } catch (e) {
      'Open store failed: $e'.Log('AppUpdate');
      return Error(CcDeviceFailure('Could not open the app store: $e'));
    }
  }
}
