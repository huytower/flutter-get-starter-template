import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../notification/domain/usecases/check_audit_reminder_usecase.dart';
import '../../domain/entities/reconciliation_availability_entity.dart';
import '../../domain/entities/reconciliation_entity.dart';
import '../../domain/usecases/get_reconciliation_availability_usecase.dart';
import '../../domain/usecases/get_reconciliation_history_usecase.dart';
import '../../domain/usecases/perform_reconciliation_usecase.dart';
import '../../domain/usecases/undo_reconciliation_usecase.dart';

/// The reconciliation records the page reads and writes, and what each write
/// changes outside the page: recording or undoing one opens or closes the
/// audit cycle, so the audit reminders are re-evaluated right away instead of
/// at the next app launch.
@injectable
class ReconciliationRecordActions {
  ReconciliationRecordActions(
    this._perform,
    this._undo,
    this._history,
    this._availability,
    this._auditReminder,
  );

  final PerformReconciliationUseCase _perform;
  final UndoReconciliationUseCase _undo;
  final GetReconciliationHistoryUseCase _history;
  final GetReconciliationAvailabilityUseCase _availability;
  final CheckAuditReminderUseCase _auditReminder;

  Future<Result<List<ReconciliationEntity>, CcFailure>> history() => _history();

  Future<Result<ReconciliationAvailabilityEntity, CcFailure>> availability() =>
      _availability();

  Future<Result<ReconciliationEntity, CcFailure>> perform(
    Map<String, int> actualByWalletId, {
    ({int systemTotal, int actualTotal, String currencyCode})? displayTotals,
  }) async {
    final result = await _perform(
      actualByWalletId,
      displayTotals: displayTotals,
    );
    if (result.isSuccess()) await _auditReminder();
    return result;
  }

  Future<Result<void, CcFailure>> undo() async {
    final result = await _undo();
    if (result.isSuccess()) await _auditReminder();
    return result;
  }
}
