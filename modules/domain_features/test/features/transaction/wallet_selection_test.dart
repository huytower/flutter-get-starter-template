import 'dart:io';

import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/get_x/prj_get_controller.dart';
import 'package:domain_features/core/presentation/helper/last_entry_wallet.dart';
import 'package:domain_features/features/transaction/presentation/get_x/wallet_selection_mixin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive_ce.dart';

/// Simulation of the entry forms' wallet selection: "TCB 1234" stays selected
/// after a submit reloads the wallets, in every form and after a restart.
class _Form extends PrjGetController with WalletSelectionMixin {
  _Form({this.hasEditing = false});

  @override
  final bool hasEditing;
}

WalletEntity _wallet(String id, [String type = WalletType.bank]) =>
    WalletEntity(
      id: id,
      name: id,
      balance: 0,
      iconCode: 0,
      type: type,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  late Directory dir;
  final all = [
    _wallet('cash', WalletType.cash),
    _wallet('tcb'),
    _wallet('stock', WalletType.investment),
  ];

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('wallet_selection');
    Hive.init(dir.path);
    await PrjAppStorage.register();
  });

  setUp(() async {
    PrjAppStorage.instance.lastEntryWalletId = null;
    LastEntryWallet.changes.value = null;
    await PrjAppStorage.instance.save();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('first use selects the first liquid wallet', () {
    final form = _Form()..bindWallets(all.obs);

    expect(form.selectedWalletId.value, 'cash');
    expect(form.wallets.map((w) => w.id), ['cash', 'tcb']);
  });

  test('a reload (assignAll empties first) keeps the selection', () {
    final source = <WalletEntity>[...all].obs;
    final form = _Form()..bindWallets(source);
    form.setWalletId('tcb');

    // What TransactionController.loadWallets does after every submit.
    source.assignAll(all);
    form.bindWallets(source);

    expect(form.selectedWalletId.value, 'tcb');
  });

  test(
    'other open forms follow, and a new form (restart) preselects it',
    () async {
      final expense = _Form()..bindWallets(all.obs);
      final income = _Form()..bindWallets(all.obs);

      expense.setWalletId('tcb');
      await Future<void>.delayed(Duration.zero);

      expect(income.selectedWalletId.value, 'tcb');
      expect(PrjAppStorage.instance.lastEntryWalletId, 'tcb');
      final afterRestart = _Form()..bindWallets(<WalletEntity>[].obs);
      expect(afterRestart.selectedWalletId.value, isNull);
      afterRestart.applyWallets(all);
      expect(afterRestart.selectedWalletId.value, 'tcb');
    },
  );

  test('a deleted wallet falls back to the first one', () {
    final source = <WalletEntity>[...all].obs;
    final form = _Form()..bindWallets(source);
    form.setWalletId('tcb');

    source.assignAll([all.first]);

    expect(form.selectedWalletId.value, 'cash');
  });

  test('editing an old entry never changes the remembered wallet', () async {
    final entry = _Form()..bindWallets(all.obs);
    entry.setWalletId('tcb');
    final editing = _Form(hasEditing: true)..bindWallets(all.obs);

    editing.setWalletId('cash');
    await Future<void>.delayed(Duration.zero);

    expect(editing.selectedWalletId.value, 'cash');
    expect(entry.selectedWalletId.value, 'tcb');
    expect(PrjAppStorage.instance.lastEntryWalletId, 'tcb');
  });
}
