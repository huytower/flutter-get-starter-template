import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/data/repositories/prj_base_repository.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/pending_cloud_deletes.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local/wallet_local_datasource.dart';
import '../datasources/wallet_sync_datasource.dart';
import '../models/wallet_hive_model.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl with PrjBaseRepository implements WalletRepository {
  @factoryMethod
  WalletRepositoryImpl({
    required this.crashReporter,
    required WalletLocalDataSource local,
    required WalletSyncDataSource sync,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _sync = sync,
       _syncService = syncService;

  @override
  final CcCrashReporter crashReporter;
  final WalletLocalDataSource _local;
  final WalletSyncDataSource _sync;
  final FinancialDataSyncService _syncService;

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

  /// A missing wallet is an expected outcome (deleted, or replaced by a sync,
  /// while a form still held its id), not a bug: it comes back as a
  /// [CcValidationFailure] the UI can show, and is not sent to the crash
  /// reporter the way an exception inside [safeRequest] would be.
  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) async {
    final result = await safeRequest(() => _local.getWallet(id));
    if (result.isError()) return Error(result.tryGetError()!);
    final wallet = result.tryGetSuccess();
    if (wallet == null) return _walletNotFound(id);
    return Success(wallet);
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
  Future<Result<void, CcFailure>> deleteWallet(String id) async {
    final modelResult = await safeRequest(() => _local.getWalletModel(id));
    if (modelResult.isError()) return Error(modelResult.tryGetError()!);
    final walletModel = modelResult.tryGetSuccess();
    if (walletModel == null) return _walletNotFound(id);

    return safeRequest(() async {
      await _local.deleteWallet(id);
      '[DeleteWallet] local wallet deleted id=$id remoteId=${walletModel.remoteId}'
          .Log('DeleteWallet');
      // Queued, never awaited: offline, Firestore answers a write only once
      // the server has it. syncAll() deletes the document when online, and
      // until then the pull can't bring the wallet back.
      await PendingCloudDeletes.add('wallets', [id, walletModel.remoteId]);
      _syncService.syncAll();
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

  Error<T, CcFailure> _walletNotFound<T>(String id) {
    'Wallet not found: $id'.Log('WalletRepository');
    return const Error(CcValidationFailure(PrjLocaleKeys.wallet_not_found));
  }

  Future<void> _syncWallet(String id) async {
    try {
      final wallet = await _local.getWalletModel(id);
      if (wallet == null) return;

      final remoteId = await _sync.syncWallet(wallet);
      // Deleted while uploading: writing it back would bring it back.
      final current = await _local.getWalletModel(id);
      if (remoteId == null || current == null) return;
      await _local.updateWalletModel(
        current.copyWithSyncMetadata(
          current.syncMetadata.copyWith(
            remoteId: remoteId,
            // Edited meanwhile: stays pending so the edit is uploaded too.
            status: identical(current, wallet)
                ? SyncStatus.synced
                : SyncStatus.pending,
            lastSyncedAt: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      'Sync failed for wallet $id: $e'.Log('WalletRepository');
    }
  }
}
