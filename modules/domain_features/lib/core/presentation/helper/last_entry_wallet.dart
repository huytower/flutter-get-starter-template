import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:app_config/data/datasources/local/box/prj_hive_box.dart';
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:get/get.dart';
import 'package:hive_ce/hive_ce.dart';

/// The liquid wallet last used for a transaction, shared by every entry form
/// and kept across app launches
/// ([PrjAppStorage.lastEntryWalletId], a per-account value cleared when the
/// device changes owner).
abstract final class LastEntryWallet {
  /// Emits the wallet id each time a new one is remembered, so the other
  /// forms already built can follow.
  static final RxnString changes = RxnString();

  static bool get _hasStorage => Hive.isBoxOpen(PrjHiveBox.APP_BOX_NAME);

  static String? get id =>
      _hasStorage ? PrjAppStorage.instance.lastEntryWalletId : null;

  static Future<void> remember(String? walletId) async {
    if (walletId == null || walletId.isEmpty) return;
    final isNew =
        _hasStorage && walletId != PrjAppStorage.instance.lastEntryWalletId;
    if (isNew) PrjAppStorage.instance.lastEntryWalletId = walletId;
    // Tell the other forms at once, even when the id is unchanged (one of them
    // may have been moved by a suggestion), then persist.
    changes.trigger(walletId);
    if (isNew) {
      '[EntryWallet] remembered $walletId'.Log('EntryWallet');
      await PrjAppStorage.instance.save();
    }
  }
}
