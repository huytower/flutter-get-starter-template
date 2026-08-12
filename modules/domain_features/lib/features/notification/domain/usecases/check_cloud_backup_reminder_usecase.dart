import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';

import '../../../profile/domain/repositories/profile_repository.dart';
import '../../notification_service.dart';
import '../../reminder_ids.dart';

/// Re-evaluated on every app open: if the user is still a guest 2 weeks
/// after first install and hasn't been nudged yet, fires a one-time local
/// notification encouraging them to register (so their data backs up to
/// Cloud instead of staying local-only). Fire-if-due rather than
/// schedule-once, so it naturally never fires for a user who has since
/// registered — no need to hunt down every login/registration success path
/// to cancel a stale future notification.
@lazySingleton
class CheckCloudBackupReminderUseCase {
  CheckCloudBackupReminderUseCase(
    this._profileRepository,
    this._session,
    this._notificationService,
  );

  final ProfileRepository _profileRepository;
  final SessionContract _session;
  final NotificationService _notificationService;

  static const _delay = Duration(days: 14);

  Future<void> call() async {
    if (_session.currentUser != null) return;

    final settings = await _profileRepository.getSettings();
    if (!settings.reminderEnabled) return;
    if (settings.cloudBackupReminderSentAt != null) return;

    final firstLaunchAt = settings.firstLaunchAt;
    if (firstLaunchAt == null) return;
    if (DateTime.now().isBefore(firstLaunchAt.add(_delay))) return;

    await _notificationService.showNow(
      id: ReminderIds.cloudBackup,
      title: el.tr(CcLocaleKeys.notification_cloud_backup_title),
      body: el.tr(CcLocaleKeys.notification_cloud_backup_body),
    );
    await _profileRepository.saveSettings(
      settings.copyWith(cloudBackupReminderSentAt: DateTime.now()),
    );
  }
}
