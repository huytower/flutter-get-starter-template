import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/wallet_entity.dart';

@lazySingleton
class WalletLocalDataSource {
  Future<Box<WalletEntity>> get _box async {
    return await Hive.openBox<WalletEntity>(CcHiveBox.WALLET_BOX_NAME);
  }

  Future<List<WalletEntity>> getWallets() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<WalletEntity?> getWallet(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> addWallet(WalletEntity wallet) async {
    final box = await _box;
    await box.put(wallet.id, wallet);
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    final box = await _box;
    await box.put(wallet.id, wallet);
  }

  Future<void> deleteWallet(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
