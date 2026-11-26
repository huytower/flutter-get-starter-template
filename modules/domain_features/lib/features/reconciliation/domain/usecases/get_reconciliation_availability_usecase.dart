import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../profile/domain/repositories/profile_repository.dart';
import '../entities/reconciliation_availability_entity.dart';
import '../reconciliation_period_utils.dart';
import '../repositories/reconciliation_repository.dart';

/// Decides whether the user may reconcile today.
///
/// The rule: one reconciliation per audit cycle (the 7 days ending on the
/// audit day, see [auditCycleOf]), on any day of the cycle. Reconciling early
/// closes the cycle; the next one opens the day after the audit day.
///
/// Changing the audit day in Profile re-opens reconciliation at once: a
/// reconciliation made before `ProfileSettingsEntity.weeklyAuditDayChangedAt`
/// does not close the new cycle.
@injectable
class GetReconciliationAvailabilityUseCase {
  GetReconciliationAvailabilityUseCase(
    this._profileRepository,
    this._reconciliationRepository,
  );

  final ProfileRepository _profileRepository;
  final ReconciliationRepository _reconciliationRepository;

  Future<Result<ReconciliationAvailabilityEntity, CcFailure>> call({
    DateTime? now,
  }) async {
    final settings = await _profileRepository.getSettings();
    final auditWeekday = settings.weeklyAuditDayIndex + 1;
    final cycle = auditCycleOf(now ?? DateTime.now(), auditWeekday);

    final latestResult = await _reconciliationRepository.getLatest();
    if (latestResult.isError()) return Error(latestResult.tryGetError()!);
    final latest = latestResult.tryGetSuccess();

    final changedAt = settings.weeklyAuditDayChangedAt;
    final hasClosedCycle =
        latest != null &&
        auditCycleOf(latest.date, auditWeekday) == cycle &&
        (changedAt == null || latest.date.isAfter(changedAt));

    return Success(
      ReconciliationAvailabilityEntity(
        cycleStart: cycle.start,
        cycleEnd: cycle.end,
        reconciledAt: hasClosedCycle ? latest.date : null,
      ),
    );
  }
}
