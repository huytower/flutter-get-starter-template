import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/wallet_entity.dart';
import '../../models/wallet_hive_model.dart';

@lazySingleton
class WalletLocalDataSource {
  Future<Box<WalletHiveModel>> get _box async {
    return Hive.openBox<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
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
}
