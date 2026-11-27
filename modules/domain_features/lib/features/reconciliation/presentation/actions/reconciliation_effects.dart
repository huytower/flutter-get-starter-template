import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/contracts/financial_refresh_provider.dart';
import '../../../notification/domain/usecases/check_audit_reminder_usecase.dart';

/// What recording or undoing a reconciliation changes outside its page: the
/// audit cycle closes or re-opens, and adjustment entries appear or go.
@injectable
class ReconciliationEffects {
  ReconciliationEffects(this._auditReminder, this._refresh);

  final CheckAuditReminderUseCase _auditReminder;
  final FinancialRefreshProvider _refresh;

  /// Re-schedules the audit reminders now instead of at the next launch, and
  /// reloads the screens showing balances and entries (without waiting).
  Future<void> recordsChanged() async {
    await _auditReminder();
    unawaited(_reloadScreens());
  }

  Future<void> _reloadScreens() async {
    await _refresh.refreshAllLoaded();
    await _refresh.refreshBudgetLimits();
    await _refresh.refreshReport(showLoading: false);
  }
}
