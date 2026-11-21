import 'dart:async';

import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/services/emergency_fund_access.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';
import 'package:domain_features/features/wallet/domain/usecases/load_wallet_overview_usecase.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_change_effects.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

final _epoch = DateTime.utc(2026);

final _wallet = WalletEntity(
  id: 'cash',
  name: 'cash',
  balance: 0,
  iconCode: 0,
  type: WalletType.cash,
  createdAt: _epoch,
  updatedAt: _epoch,
);

class _FakeOverview implements LoadWalletOverviewUseCase {
  int calls = 0;

  @override
  Future<Result<WalletOverview, CcFailure>> call() async {
    calls++;
    return Success((
      settings: const ProfileSettingsEntity(),
      wallets: [_wallet],
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Counts balance rebuilds; each one waits for [release] so calls can overlap.
class _GatedLedger implements WalletLedger {
  int builds = 0;
  Completer<void> gate = Completer<void>();

  void release() {
    gate.complete();
    gate = Completer<void>();
  }

  @override
  Future<WalletLedgerSnapshot> build(
    List<WalletEntity> wallets,
    String targetCurrency,
  ) async {
    builds++;
    await gate.future;
    return const WalletLedgerSnapshot(
      walletsWithTransactions: {},
      bookBalances: {},
      investmentStats: {},
      monthlyInvestmentStats: {},
    );
  }

  @override
  Future<Map<String, int>> displayBalances(
    List<WalletEntity> wallets,
    int Function(String walletId) bookBalanceOf,
    String targetCurrency,
  ) async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Unused implements WalletRepository, EmergencyFundAccess, WalletChangeEffects {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeOverview overview;
  late _GatedLedger ledger;
  late WalletController controller;

  setUp(() {
    overview = _FakeOverview();
    ledger = _GatedLedger();
    final unused = _Unused();
    controller = WalletController(unused, overview, ledger, unused, unused);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a forced refresh during a rebuild does not rebuild again', () async {
    // The pattern in the app log: one save marks the data dirty, then two
    // refresh paths reload at once (a plain load and a forced one).
    controller.markDirty();
    final first = controller.loadWallets();
    final second = controller.loadWallets(forceRefresh: true);
    await settle();
    expect(ledger.builds, 1);

    ledger.release();
    await Future.wait([first, second]);

    expect(ledger.builds, 1);
    expect(overview.calls, 2, reason: 'the follow-up still re-reads wallets');
  });

  test('a change marked after the build started gets one more rebuild', () async {
    final first = controller.loadWallets();
    await settle();
    expect(ledger.builds, 1);

    controller.markDirty();
    final second = controller.loadWallets();
    final third = controller.loadWallets(forceRefresh: true);

    ledger.release();
    await settle();
    ledger.release();
    await Future.wait([first, second, third]);

    expect(ledger.builds, 2);
    expect(overview.calls, 2, reason: 'calls made meanwhile share one load');
  });

  test('a failed rebuild leaves the data dirty for the next load', () async {
    final failing = _ThrowingLedger();
    final unused = _Unused();
    controller = WalletController(unused, overview, failing, unused, unused);

    await expectLater(controller.loadWallets(), throwsStateError);
    failing.fail = false;
    await controller.loadWallets();

    expect(failing.builds, 2);
  });
}

class _ThrowingLedger extends _GatedLedger {
  bool fail = true;

  @override
  Future<WalletLedgerSnapshot> build(
    List<WalletEntity> wallets,
    String targetCurrency,
  ) async {
    builds++;
    if (fail) throw StateError('ledger');
    return const WalletLedgerSnapshot(
      walletsWithTransactions: {},
      bookBalances: {},
      investmentStats: {},
      monthlyInvestmentStats: {},
    );
  }
}
