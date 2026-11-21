import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/data/repository/cc_base_repository.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local/wallet_local_datasource.dart';
import '../datasources/wallet_sync_datasource.dart';
import '../models/wallet_hive_model.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl with CcBaseRepository implements WalletRepository {
  @factoryMethod
  WalletRepositoryImpl({
    required this.crashReporter,
    required WalletLocalDataSource local,
    required WalletSyncDataSource sync,
  }) : _local = local,
       _sync = sync;

  @override
  final CcCrashReporter crashReporter;
  final WalletLocalDataSource _local;
  final WalletSyncDataSource _sync;

  @override
  Future<Result<List<WalletEntity>, CcFailure>> getWallets() {
    return safeRequest(() async {
      final wallets = await _local.getWallets();
      wallets.sort((a, b) {
        final aCash = a.type == WalletType.cash ? 0 : 1;
        final bCash = b.type == WalletType.cash ? 0 : 1;
        if (aCash != bCash) return aCash - bCash;
        return a.createdAt.compareTo(b.createdAt);
      });
      return wallets;
    });
  }

  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) {
    return safeRequest(() async {
      final wallet = await _local.getWallet(id);
      if (wallet == null) {
        throw StateError('Wallet not found: $id');
      }
      return wallet;
    });
  }

  @override
  Future<Result<void, CcFailure>> addWallet(WalletEntity wallet) {
    return safeRequest(() async {
      await _local.addWallet(wallet);
      _syncWallet(wallet.id);
    });
  }

  @override
  Future<Result<void, CcFailure>> updateWallet(WalletEntity wallet) {
    return safeRequest(() async {
      await _local.updateWallet(wallet);
      _syncWallet(wallet.id);
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteWallet(String id) {
    return safeRequest(() async {
      final walletModel = await _local.getWalletModel(id);
      if (walletModel == null) {
        throw StateError('Wallet not found: $id');
      }
      await _local.deleteWallet(id);
      if (walletModel.remoteId != null) {
        try {
          await _sync.deleteWallet(walletModel.remoteId!);
        } catch (e) {
          'Remote delete failed: $e'.Log('WalletRepository');
        }
      }
    });
  }

  @override
  Future<Result<void, CcFailure>> syncWallet(String id) {
    return safeRequest(() => _syncWallet(id));
  }

  @override
  Future<Result<void, CcFailure>> syncFromFirestore() {
    return safeRequest(() async {
      final remoteWallets = await _sync.fetchWallets();
      for (final remoteWallet in remoteWallets) {
        final localId = remoteWallet['localId'] as String;
        final existing = await _local.getWallet(localId);

        if (existing == null) {
          final walletModel = WalletHiveModel.fromFirestoreData(
            remoteWallet,
            localId,
          );
          await _local.addWalletModel(walletModel);
        } else {
          final walletModel = WalletHiveModel.fromFirestoreData(
            remoteWallet,
            localId,
          );
          await _local.updateWalletModel(walletModel);
        }
      }
    });
  }

  Future<void> _syncWallet(String id) async {
    try {
      final wallet = await _local.getWalletModel(id);
      if (wallet == null) return;

      final remoteId = await _sync.syncWallet(wallet);
      if (remoteId != null) {
        final updated = wallet.copyWithSyncMetadata(
          wallet.syncMetadata.copyWith(
            remoteId: remoteId,
            status: SyncStatus.synced,
            lastSyncedAt: DateTime.now(),
          ),
        );
        await _local.updateWalletModel(updated);
      }
    } catch (e) {
      'Sync failed for wallet $id: $e'.Log('WalletRepository');
    }
  }
}
