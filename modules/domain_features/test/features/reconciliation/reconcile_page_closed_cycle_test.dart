import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_availability_entity.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/presentation/actions/reconciliation_record_actions.dart';
import 'package:domain_features/features/reconciliation/presentation/get_x/reconciliation_controller.dart';
import 'package:domain_features/features/reconciliation/presentation/pages/reconcile_page.dart';
import 'package:domain_features/features/reconciliation/presentation/widgets/reconciliation_confirm_button.dart';
import 'package:domain_features/features/reconciliation/presentation/widgets/reconciliation_description_banner.dart';
import 'package:domain_features/features/reconciliation/presentation/widgets/reconciliation_history_card.dart';
import 'package:domain_features/features/reconciliation/presentation/widgets/reconciliation_success_sheet.dart';
import 'package:domain_features/features/reconciliation/presentation/widgets/reconciliation_summary.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/services/emergency_fund_access.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_balances_usecase.dart';
import 'package:domain_features/features/wallet/domain/usecases/load_wallet_overview_usecase.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_change_effects.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart';
// Loads the real strings without the EasyLocalization widget and its storage.
// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Translations;
import 'package:message/export_message.dart';

ReconciliationAvailabilityEntity _cycle({DateTime? reconciledAt}) =>
    ReconciliationAvailabilityEntity(
      cycleStart: DateTime.utc(2026, 11, 23),
      cycleEnd: DateTime.utc(2026, 11, 29),
      reconciledAt: reconciledAt,
    );

final _record = ReconciliationEntity(
  id: 'r1',
  year: 2026,
  week: 48,
  systemTotal: 100,
  actualTotal: 100,
  difference: 0,
  allocations: const [],
  adjustmentTransactionIds: const [],
  date: DateTime(2026, 11, 28),
);

final _older = ReconciliationEntity(
  id: 'r0',
  year: 2026,
  week: 47,
  systemTotal: 90,
  actualTotal: 90,
  difference: 0,
  allocations: const [],
  adjustmentTransactionIds: const [],
  date: DateTime(2026, 11, 21),
);

class _NoBalances implements GetWalletBalancesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRecords implements ReconciliationRecordActions {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoUserLevel implements UserLevelProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoWallets implements WalletRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoOverview implements LoadWalletOverviewUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoLedger implements WalletLedger {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoEmergencyFund implements EmergencyFundAccess {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoEffects implements WalletChangeEffects {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The summary only reads the display currency from the wallet controller.
class _FakeWalletController extends WalletController {
  _FakeWalletController()
    : super(
        _NoWallets(),
        _NoOverview(),
        _NoLedger(),
        _NoEmergencyFund(),
        _NoEffects(),
      );

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  void onReady() {}
}

/// The page controller without its data: the test sets the cycle itself.
class _FakeController extends ReconciliationController {
  _FakeController() : super(_NoBalances(), _NoRecords(), _NoUserLevel());

  @override
  // ignore: must_call_super
  void onInit() => layoutStatus.value = CcLayoutStatus.success;

  @override
  // ignore: must_call_super
  void onReady() {}

  @override
  bool get canReconcile => true;

  int undoCount = 0;

  /// A successful undo drops the latest record and re-opens the cycle.
  @override
  Future<String?> undoLast() async {
    undoCount++;
    history.removeAt(0);
    cycle.value = _cycle();
    return null;
  }

  /// A successful confirmation closes the cycle.
  @override
  Future<String?> performReconciliation() async {
    cycle.value = _cycle(reconciledAt: DateTime(2026, 11, 28));
    return null;
  }
}

final _undoButton = find.byIcon(Icons.undo_rounded);

void main() {
  late _FakeController controller;

  setUpAll(() async {
    const locale = Locale('vi');
    final strings = await const CodegenLoader().load('', locale);
    Localization.load(locale, translations: Translations(strings!));
  });

  setUp(() {
    controller = _FakeController();
    controller.history.add(_record);
    Get.put<ReconciliationController>(controller);
    Get.put<WalletController>(_FakeWalletController());
  });
  tearDown(Get.reset);

  Future<void> openPage(WidgetTester tester) async {
    // A wide phone: the test font is wider than the real one.
    tester.view.physicalSize = const Size(590, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReconcilePage()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('closed cycle: only the history', (tester) async {
    controller.cycle.value = _cycle(reconciledAt: DateTime(2026, 11, 28));
    await openPage(tester);

    expect(find.byType(ReconciliationHistoryCard), findsOneWidget);
    expect(find.byType(ReconciliationConfirmButton), findsNothing);
    expect(find.byType(ReconciliationSummary), findsNothing);
    expect(find.byType(ReconciliationDescriptionBanner), findsNothing);
  });

  testWidgets('open cycle: the full form', (tester) async {
    controller.cycle.value = _cycle();
    await openPage(tester);

    expect(find.byType(ReconciliationConfirmButton), findsOneWidget);
    expect(find.byType(ReconciliationSummary), findsOneWidget);
    expect(find.byType(ReconciliationDescriptionBanner), findsOneWidget);
  });

  testWidgets('only the latest record can be undone', (tester) async {
    controller.history.add(_older);
    controller.cycle.value = _cycle(reconciledAt: DateTime(2026, 11, 28));
    await openPage(tester);

    expect(find.byType(ReconciliationHistoryCard), findsNWidgets(2));
    expect(_undoButton, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ReconciliationHistoryCard).first,
        matching: _undoButton,
      ),
      findsOneWidget,
    );
  });

  testWidgets('an open cycle offers no undo', (tester) async {
    controller.cycle.value = _cycle();
    await openPage(tester);
    await tester.scrollUntilVisible(
      find.byType(ReconciliationHistoryCard),
      300,
    );

    expect(_undoButton, findsNothing);
  });

  testWidgets('undo asks first, then re-opens the cycle', (tester) async {
    controller.cycle.value = _cycle(reconciledAt: DateTime(2026, 11, 28));
    await openPage(tester);

    await tester.tap(_undoButton);
    await tester.pumpAndSettle();
    expect(find.byType(CcConfirmSheet), findsOneWidget);
    expect(controller.undoCount, 0);

    await tester.tap(
      find.descendant(
        of: find.byType(CcConfirmSheet),
        matching: find.byWidgetPredicate(
          (widget) => widget is CcBaseButton && widget.title == 'Hoàn tác',
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Let the buttons' debounce timers run out.
    await tester.pump(const Duration(seconds: 2));

    expect(controller.undoCount, 1);
    expect(find.byType(ReconciliationConfirmButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirming hides the form, then success leaves the page', (
    tester,
  ) async {
    controller.cycle.value = _cycle();
    await openPage(tester);

    await tester.tap(find.byType(ReconciliationConfirmButton));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ReconciliationSuccessSheet), findsOneWidget);
    expect(find.byType(ReconciliationConfirmButton), findsNothing);

    // The success sheet closes itself, then the page.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ReconciliationSuccessSheet), findsNothing);
    expect(find.byType(ReconcilePage), findsNothing);
  });
}
