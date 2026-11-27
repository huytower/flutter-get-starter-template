import 'dart:async';

import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/features/notification/domain/usecases/check_audit_reminder_usecase.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_availability_entity.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/presentation/actions/reconciliation_effects.dart';
import 'package:domain_features/features/reconciliation/presentation/actions/reconciliation_record_actions.dart';
import 'package:domain_features/features/reconciliation/presentation/get_x/reconciliation_controller.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_balance_entity.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_balances_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

class _Reminder implements CheckAuditReminderUseCase {
  _Reminder(this.calls);

  final List<String> calls;

  @override
  Future<void> call() async => calls.add('reminder');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Refresh implements FinancialRefreshProvider {
  _Refresh(this.calls);

  final List<String> calls;

  @override
  Future<void> refreshAllLoaded() async => calls.add('screens');

  @override
  Future<void> refreshBudgetLimits() async => calls.add('limits');

  @override
  Future<void> refreshReport({bool showLoading = true}) async =>
      calls.add('report loader=$showLoading');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Undo succeeds at once; the history read waits until the test lets it go.
class _SlowRecords implements ReconciliationRecordActions {
  final historyRead =
      Completer<Result<List<ReconciliationEntity>, CcFailure>>();

  @override
  Future<Result<void, CcFailure>> undo() async => const Success(null);

  @override
  Future<Result<List<ReconciliationEntity>, CcFailure>> history() =>
      historyRead.future;

  @override
  Future<Result<ReconciliationAvailabilityEntity, CcFailure>>
  availability() async => Success(
    ReconciliationAvailabilityEntity(
      cycleStart: DateTime.utc(2026, 11, 23),
      cycleEnd: DateTime.utc(2026, 11, 29),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnreadableBalances implements GetWalletBalancesUseCase {
  @override
  Future<Result<List<WalletBalanceEntity>, CcFailure>> call() async =>
      const Error(CcValidationFailure('not needed here'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UserLevel implements UserLevelProvider {
  @override
  Future<void> refresh() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a recorded change reloads reminders, screens and report', () async {
    final calls = <String>[];
    await ReconciliationEffects(
      _Reminder(calls),
      _Refresh(calls),
    ).recordsChanged();
    await pumpEventQueue();

    expect(calls, ['reminder', 'screens', 'limits', 'report loader=false']);
  });

  test('undo stays busy until the cycle reads open again', () async {
    final records = _SlowRecords();
    final controller = ReconciliationController(
      _UnreadableBalances(),
      records,
      _UserLevel(),
    );

    final undo = controller.undoLast();
    await pumpEventQueue();
    // A second undo now would hit the reconciliation before this one.
    expect(controller.hasSubmitting.value, isTrue);

    records.historyRead.complete(const Success([]));
    expect(await undo, isNull);
    expect(controller.hasSubmitting.value, isFalse);
    expect(controller.cycle.value?.hasReconciledThisCycle, isFalse);
  });
}
