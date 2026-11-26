import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';
import 'package:message/prj_locale_keys.dart';

import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../reconciliation/domain/usecases/get_reconciliation_availability_usecase.dart';
import '../../notification_service.dart';
import '../../reminder_ids.dart';

/// Re-evaluated on every app open and after each reconciliation or undo
/// (idempotent — cancels and reschedules against fixed ids, so re-running
/// never duplicates a pending reminder).
///
/// Schedules at most 2 local notifications for the current audit cycle: one
/// the day before the audit day ("approaching"), one on the audit day itself
/// ("due"). Both are cancelled once the cycle already has a reconciliation
/// (the next one is not allowed until the cycle ends), or if the "Nhắc nhở"
/// master toggle is off.
@lazySingleton
class CheckAuditReminderUseCase {
  CheckAuditReminderUseCase(
    this._profileRepository,
    this._getAvailability,
    this._notificationService,
  );

  final ProfileRepository _profileRepository;
  final GetReconciliationAvailabilityUseCase _getAvailability;
  final NotificationService _notificationService;

  static const _hour = 9;

  Future<void> call() async {
    final settings = await _profileRepository.getSettings();
    if (!settings.reminderEnabled) {
      await _cancelBoth();
      return;
    }

    final availability = (await _getAvailability()).tryGetSuccess();
    if (availability == null || availability.hasReconciledThisCycle) {
      // Already reconciled this cycle — nothing to remind about.
      await _cancelBoth();
      return;
    }

    final auditDay = availability.cycleEnd;
    await _notificationService.scheduleAt(
      id: ReminderIds.auditApproaching,
      title: el.tr(PrjLocaleKeys.notification_audit_approaching_title),
      body: el.tr(PrjLocaleKeys.notification_audit_approaching_body),
      dateTime: DateTime(
        auditDay.year,
        auditDay.month,
        auditDay.day - 1,
        _hour,
      ),
    );
    await _notificationService.scheduleAt(
      id: ReminderIds.auditDue,
      title: el.tr(PrjLocaleKeys.notification_audit_due_title),
      body: el.tr(PrjLocaleKeys.notification_audit_due_body),
      dateTime: DateTime(auditDay.year, auditDay.month, auditDay.day, _hour),
    );
  }

  Future<void> _cancelBoth() async {
    await _notificationService.cancel(ReminderIds.auditApproaching);
    await _notificationService.cancel(ReminderIds.auditDue);
  }
}
