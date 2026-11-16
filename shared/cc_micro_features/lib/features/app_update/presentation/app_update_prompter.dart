import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../domain/entities/app_update_status_entity.dart';
import '../domain/usecases/check_app_update_usecase.dart';
import 'pages/force_update_page.dart';

/// Runs the update check and, when an update is required, covers the app
/// with [ForceUpdatePage] on the root navigator.
///
/// Call it once the first frame is on screen (e.g. from the navigation
/// shell) — it never blocks startup, and failures only log: a broken config
/// must not lock users out.
@lazySingleton
class AppUpdatePrompter {
  AppUpdatePrompter(this._checkAppUpdate);

  final CheckAppUpdateUseCase _checkAppUpdate;
  bool _isShowing = false;

  Future<void> checkAndPrompt(BuildContext context) async {
    if (_isShowing) return;
    final result = await _checkAppUpdate();
    switch (result) {
      case Error(:final error):
        'Update check skipped: ${error.message}'.Log('AppUpdate');
      case Success(success: AppUpdateNotRequired()):
        return;
      case Success(success: final AppUpdateRequired status):
        if (!context.mounted || _isShowing) return;
        _isShowing = true;
        'Forced update: ${status.currentVersion} < ${status.minimumVersion}'
            .Log('AppUpdate');
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ForceUpdatePage(status: status),
          ),
        );
        _isShowing = false;
    }
  }
}
