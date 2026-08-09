import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../reconciliation/domain/reconciliation_period_utils.dart';
import '../../../reconciliation/domain/repositories/reconciliation_repository.dart';
import '../../notification_service.dart';
import '../../reminder_ids.dart';

/// Re-evaluated on every app open (idempotent — cancels and reschedules
/// against fixed ids, so re-running never duplicates a pending reminder).
///
/// Schedules at most 2 local notifications for the user's configured weekly
/// audit day: one the day before ("approaching"), one on the day itself
/// ("due"). Both are skipped/cancelled once the user has already reconciled
/// this ISO week, or if the "Nhắc nhở" master toggle is off.
@lazySingleton
class CheckAuditReminderUseCase {
  CheckAuditReminderUseCase(
    this._profileRepository,
    this._reconciliationRepository,
    this._notificationService,
  );

  final ProfileRepository _profileRepository;
  final ReconciliationRepository _reconciliationRepository;
  final NotificationService _notificationService;

  static const _hour = 9;

  Future<void> call() async {
    final settings = await _profileRepository.getSettings();
    if (!settings.reminderEnabled) {
      await _cancelBoth();
      return;
    }

    final latestResult = await _reconciliationRepository.getLatest();
    final latest = latestResult.isSuccess() ? latestResult.tryGetSuccess() : null;
    final now = DateTime.now();
    if (latest != null && isoWeekOf(latest.date) == isoWeekOf(now)) {
      // Already reconciled this week — nothing to remind about.
      await _cancelBoth();
      return;
    }

    final auditWeekday = settings.weeklyAuditDayIndex + 1;
    final daysToNextAudit = (auditWeekday - now.weekday) % 7;
    final today = DateTime(now.year, now.month, now.day);
    final auditDate = today.add(Duration(days: daysToNextAudit));

    await _notificationService.scheduleAt(
      id: ReminderIds.auditApproaching,
      title: el.tr(CcLocaleKeys.notification_audit_approaching_title),
      body: el.tr(CcLocaleKeys.notification_audit_approaching_body),
      dateTime: auditDate
          .subtract(const Duration(days: 1))
          .add(const Duration(hours: _hour)),
    );
    await _notificationService.scheduleAt(
      id: ReminderIds.auditDue,
      title: el.tr(CcLocaleKeys.notification_audit_due_title),
      body: el.tr(CcLocaleKeys.notification_audit_due_body),
      dateTime: auditDate.add(const Duration(hours: _hour)),
    );
  }

  Future<void> _cancelBoth() async {
    await _notificationService.cancel(ReminderIds.auditApproaching);
    await _notificationService.cancel(ReminderIds.auditDue);
  }
}
