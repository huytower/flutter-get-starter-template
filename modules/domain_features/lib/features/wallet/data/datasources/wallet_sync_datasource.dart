import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/wallet_hive_model.dart';

@injectable
class WalletSyncDataSource {
  final GenericSyncDataSource _delegate;

  WalletSyncDataSource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(syncService, session, 'wallets');

  Future<String?> syncWallet(WalletHiveModel wallet) => _delegate.sync(
        localId: wallet.id,
        data: wallet.toFirestoreData(),
        remoteId: wallet.syncMetadata.remoteId,
        lastSyncedAt: wallet.syncMetadata.lastSyncedAt,
      );

  Future<List<Map<String, dynamic>>> fetchWallets() => _delegate.fetch();

  Future<void> deleteWallet(String remoteId) => _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamWallets() => _delegate.stream();
}
