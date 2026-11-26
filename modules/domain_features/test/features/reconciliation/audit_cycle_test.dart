import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:domain_features/features/profile/domain/repositories/profile_repository.dart';
import 'package:domain_features/features/profile/user_level/domain/usecases/reconciliation_streak_calculator.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/domain/reconciliation_period_utils.dart';
import 'package:domain_features/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:domain_features/features/reconciliation/domain/usecases/get_reconciliation_availability_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

// 2026-11-28 is a Saturday, 2026-11-29 a Sunday.
const _sunday = DateTime.sunday;
const _wednesday = DateTime.wednesday;

DateTime _day(int year, int month, int day) => DateTime.utc(year, month, day);

ReconciliationEntity _reconciliation(DateTime date, {String? id}) =>
    ReconciliationEntity(
      id: id ?? date.toIso8601String(),
      year: 0,
      week: 0,
      systemTotal: 0,
      actualTotal: 0,
      difference: 0,
      allocations: const [],
      adjustmentTransactionIds: const [],
      date: date,
    );

class _FakeProfile implements ProfileRepository {
  _FakeProfile(this.settings);

  ProfileSettingsEntity settings;

  @override
  Future<ProfileSettingsEntity> getSettings() async => settings;

  @override
  Future<void> saveSettings(ProfileSettingsEntity value) async =>
      settings = value;
}

class _FakeReconciliations implements ReconciliationRepository {
  _FakeReconciliations(this.latest);

  final ReconciliationEntity? latest;

  @override
  Future<Result<ReconciliationEntity?, CcFailure>> getLatest() async =>
      Success(latest);

  @override
  Future<Result<List<ReconciliationEntity>, CcFailure>>
  getReconciliations() async => Success([?latest]);

  @override
  Future<Result<void, CcFailure>> saveReconciliation(
    ReconciliationEntity reconciliation,
  ) async => const Success(null);

  @override
  Future<Result<void, CcFailure>> deleteReconciliation(String id) async =>
      const Success(null);
}

void main() {
  group('auditCycleOf', () {
    test('audit day Sunday: Monday to Sunday', () {
      final cycle = auditCycleOf(DateTime(2026, 11, 28, 20), _sunday);
      expect(cycle.start, _day(2026, 11, 23));
      expect(cycle.end, _day(2026, 11, 29));
    });

    test('the audit day itself ends its own cycle', () {
      expect(
        auditCycleOf(DateTime(2026, 11, 29, 23, 59), _sunday).end,
        _day(2026, 11, 29),
      );
    });

    test('the day after the audit day starts the next cycle', () {
      final cycle = auditCycleOf(DateTime(2026, 11, 30), _sunday);
      expect(cycle.start, _day(2026, 11, 30));
      expect(cycle.end, _day(2026, 12, 6));
    });

    test('audit day Wednesday: Thursday to Wednesday', () {
      expect(
        auditCycleOf(DateTime(2026, 11, 25), _wednesday).start,
        _day(2026, 11, 19),
      );
      final next = auditCycleOf(DateTime(2026, 11, 26), _wednesday);
      expect(next.start, _day(2026, 11, 26));
      expect(next.end, _day(2026, 12, 2));
    });

    test('crosses a year boundary', () {
      final cycle = auditCycleOf(DateTime(2026, 12, 30), _sunday);
      expect(cycle.start, _day(2026, 12, 28));
      expect(cycle.end, _day(2027, 1, 3));
    });
  });

  group('longestReconciliationStreak', () {
    final since = DateTime(2026, 1, 1);

    int streak(List<DateTime> dates, {int auditWeekday = _sunday}) =>
        longestReconciliationStreak(
          dates.map(_reconciliation).toList(),
          auditWeekday: auditWeekday,
          since: since,
        );

    test('a reconciliation before the audit day counts for its cycle', () {
      // Saturday, then Sunday a week later, then Friday: three cycles.
      expect(
        streak([
          DateTime(2026, 11, 28, 10),
          DateTime(2026, 12, 6, 10),
          DateTime(2026, 12, 11, 10),
        ]),
        3,
      );
    });

    test('a cycle without a reconciliation breaks the run', () {
      expect(
        streak([
          DateTime(2026, 11, 15, 10),
          DateTime(2026, 11, 22, 10),
          // 23–29/11 skipped
          DateTime(2026, 12, 6, 10),
        ]),
        2,
      );
    });

    test('two reconciliations in one cycle count once', () {
      expect(
        streak([DateTime(2026, 11, 24, 10), DateTime(2026, 11, 28, 10)]),
        1,
      );
    });

    test('continues across a year boundary', () {
      expect(
        streak([
          DateTime(2026, 12, 27, 10),
          DateTime(2027, 1, 2, 10),
          DateTime(2027, 1, 10, 10),
        ]),
        3,
      );
    });

    test('follows the configured audit day', () {
      // Audit day Wednesday: Tue 24/11 closes 19–25/11, Thu 26/11 opens
      // 26/11–2/12, so these are two consecutive cycles.
      expect(
        streak([
          DateTime(2026, 11, 24, 10),
          DateTime(2026, 11, 26, 10),
        ], auditWeekday: _wednesday),
        2,
      );
    });

    test('ignores reconciliations up to the anchor', () {
      expect(
        longestReconciliationStreak(
          [_reconciliation(DateTime(2026, 11, 22, 10))],
          auditWeekday: _sunday,
          since: DateTime(2026, 11, 23),
        ),
        0,
      );
    });
  });

  group('GetReconciliationAvailabilityUseCase', () {
    Future<bool> isClosed({
      required DateTime? latest,
      required DateTime now,
      int auditDayIndex = 6,
      DateTime? auditDayChangedAt,
    }) async {
      final useCase = GetReconciliationAvailabilityUseCase(
        _FakeProfile(
          ProfileSettingsEntity(
            weeklyAuditDayIndex: auditDayIndex,
            weeklyAuditDayChangedAt: auditDayChangedAt,
          ),
        ),
        _FakeReconciliations(latest == null ? null : _reconciliation(latest)),
      );
      final result = await useCase(now: now);
      return result.tryGetSuccess()!.hasReconciledThisCycle;
    }

    test('open when nothing was reconciled yet', () async {
      expect(await isClosed(latest: null, now: DateTime(2026, 11, 29)), false);
    });

    test('reconciled Saturday: closed on the Sunday audit day', () async {
      expect(
        await isClosed(
          latest: DateTime(2026, 11, 28, 10),
          now: DateTime(2026, 11, 29, 9),
        ),
        true,
      );
    });

    test('re-opens the day after the audit day', () async {
      expect(
        await isClosed(
          latest: DateTime(2026, 11, 28, 10),
          now: DateTime(2026, 11, 30, 8),
        ),
        false,
      );
    });

    test('reconciled Monday: closed until after the next Sunday', () async {
      expect(
        await isClosed(
          latest: DateTime(2026, 11, 30, 10),
          now: DateTime(2026, 12, 6, 20),
        ),
        true,
      );
      expect(
        await isClosed(
          latest: DateTime(2026, 11, 30, 10),
          now: DateTime(2026, 12, 7, 8),
        ),
        false,
      );
    });

    test('changing the audit day re-opens reconciliation at once', () async {
      // Reconciled Saturday morning, then picked Wednesday as the audit day
      // that afternoon: the Saturday reconciliation no longer closes a cycle.
      expect(
        await isClosed(
          latest: DateTime(2026, 11, 28, 10),
          now: DateTime(2026, 11, 28, 16),
          auditDayIndex: 2,
          auditDayChangedAt: DateTime(2026, 11, 28, 15),
        ),
        false,
      );
    });

    test(
      'a reconciliation after the audit-day change closes the cycle',
      () async {
        expect(
          await isClosed(
            latest: DateTime(2026, 11, 28, 17),
            now: DateTime(2026, 12, 1, 9),
            auditDayIndex: 2,
            auditDayChangedAt: DateTime(2026, 11, 28, 15),
          ),
          true,
        );
      },
    );
  });
}
