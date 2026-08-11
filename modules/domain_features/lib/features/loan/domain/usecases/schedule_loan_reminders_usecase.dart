import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../notification/notification_service.dart';
import '../../../notification/reminder_ids.dart';
import '../entities/loan_entity.dart';

/// Schedules the due-date reminder notifications for a just-created loan,
/// if [LoanEntity.reminderBeforeDueDate] is set:
/// - Installment ([LoanRepaymentMethod.installment]): one reminder per
///   installment, 1 day before its due date.
/// - Lump-sum ([LoanRepaymentMethod.lumpSum]): three reminders before the
///   final due date — 1 month, 1 week, and 1 day ahead.
///
/// Dates already in the past are silently skipped by
/// [NotificationService.scheduleAt] itself.
@lazySingleton
class ScheduleLoanRemindersUseCase {
  ScheduleLoanRemindersUseCase(this._notificationService);

  final NotificationService _notificationService;

  static const _hour = 9;

  Future<void> call(LoanEntity loan) async {
    if (!loan.reminderBeforeDueDate) return;

    // Each entry is (the real due date shown in the notification text, how
    // long before it to fire the reminder).
    final List<(DateTime dueDate, Duration leadTime)> plan;
    if (loan.isInstallment) {
      plan = (loan.installments ?? const [])
          .map((i) => (i.dueDate, const Duration(days: 1)))
          .toList();
    } else if (loan.finalDueDate != null) {
      plan = [
        (loan.finalDueDate!, const Duration(days: 30)),
        (loan.finalDueDate!, const Duration(days: 7)),
        (loan.finalDueDate!, const Duration(days: 1)),
      ];
    } else {
      plan = const [];
    }

    for (var i = 0; i < plan.length; i++) {
      final (dueDate, leadTime) = plan[i];
      final fireDate = dueDate.subtract(leadTime);

      await _notificationService.scheduleAt(
        id: ReminderIds.loanReminder(loan.id, i),
        title: el.tr(CcLocaleKeys.notification_loan_due_title),
        body: el.tr(
          CcLocaleKeys.notification_loan_due_body,
          namedArgs: {
            'name': loan.counterpartyName,
            'date': '${dueDate.day}/${dueDate.month}/${dueDate.year}',
          },
        ),
        dateTime: DateTime(fireDate.year, fireDate.month, fireDate.day, _hour),
      );
    }
  }
}
