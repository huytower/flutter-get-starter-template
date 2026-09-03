import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/wallet_entity.dart';
import '../../models/wallet_hive_model.dart';

/// Local (Hive) persistence for wallets.
///
/// On first launch (empty box) seeds the default Cash + Bank wallets; on
/// existing installs migrates legacy `'spending'` wallets to bank and
/// guarantees a cash wallet exists.
@lazySingleton
class WalletLocalDataSource {
  static const String cashWalletId = 'wallet_cash';
  static const String bankWalletId = 'wallet_bank';

  /// Runs the seed/migration only once per app session.
  bool _initialized = false;

  WalletHiveModel _defaultCashWallet() => WalletHiveModel(
    id: cashWalletId,
    name: 'Cash',
    balance: 0,
    iconCode: Icons.payments.codePoint,
    type: WalletType.cash,
    createdAt: DateTime.now(),
  );

  Future<Box<WalletHiveModel>> get _box async {
    if (Hive.isBoxOpen(CcHiveBox.WALLET_BOX_NAME)) {
      return Hive.box<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
    }
    final box = await Hive.openBox<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
    if (_initialized) return box;
    _initialized = true;

    if (box.isEmpty) {
      await box.putAll({
        cashWalletId: _defaultCashWallet(),
        bankWalletId: WalletHiveModel(
          id: bankWalletId,
          name: 'Bank',
          balance: 0,
          iconCode: Icons.account_balance.codePoint,
          type: WalletType.bank,
          createdAt: DateTime.now(),
        ),
      });
      return box;
    }

    // Migration: legacy wallets created before wallet types were introduced
    // are treated as bank accounts, and a cash wallet is created if missing.
    final updates = <String, WalletHiveModel>{
      for (final m in box.values)
        if (m.type != WalletType.cash &&
            m.type != WalletType.bank &&
            m.type != WalletType.ewallet &&
            m.type != WalletType.investment &&
            m.type != WalletType.emergencyFund)
          m.id: WalletHiveModel(
            id: m.id,
            name: m.name,
            balance: m.balance,
            iconCode: Icons.account_balance.codePoint,
            type: WalletType.bank,
            createdAt: m.createdAt,
          ),
    };
    if (!box.values.any((m) => m.type == WalletType.cash)) {
      updates[cashWalletId] = _defaultCashWallet();
    }
    if (updates.isNotEmpty) await box.putAll(updates);
    return box;
  }

  Future<List<WalletEntity>> getWallets() async {
    final box = await _box;
    return box.values.map((m) => m.toEntity()).toList();
  }

  Future<WalletEntity?> getWallet(String id) async {
    final box = await _box;
    return box.get(id)?.toEntity();
  }

  Future<void> addWallet(WalletEntity wallet) async {
    final box = await _box;
    await box.put(wallet.id, WalletHiveModel.fromEntity(wallet));
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    final box = await _box;
    await box.put(wallet.id, WalletHiveModel.fromEntity(wallet));
  }

  Future<void> deleteWallet(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<WalletHiveModel?> getWalletModel(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> addWalletModel(WalletHiveModel wallet) async {
    final box = await _box;
    await box.put(wallet.id, wallet);
  }

  Future<void> updateWalletModel(WalletHiveModel wallet) async {
    final box = await _box;
    await box.put(wallet.id, wallet);
  }
}
