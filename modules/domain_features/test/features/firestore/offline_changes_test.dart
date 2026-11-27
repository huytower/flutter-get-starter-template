import 'dart:async';
import 'dart:io';

import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:cc_sdk/export_cc_sdk.dart' show CcNoopCrashReporter;
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/pending_cloud_deletes.dart';
import 'package:domain_features/features/firestore/upload_write_back.dart';
import 'package:domain_features/features/wallet/data/datasources/local/wallet_local_datasource.dart';
import 'package:domain_features/features/wallet/data/datasources/wallet_sync_datasource.dart';
import 'package:domain_features/features/wallet/data/models/wallet_hive_model.dart';
import 'package:domain_features/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

class _Local implements WalletLocalDataSource {
  final Map<String, WalletHiveModel> wallets = {'w1': _wallet('SJC')};

  @override
  Future<WalletHiveModel?> getWalletModel(String id) async => wallets[id];

  @override
  Future<void> updateWalletModel(WalletHiveModel wallet) async =>
      wallets[wallet.id] = wallet;

  @override
  Future<void> deleteWallet(String id) async => wallets.remove(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Firestore offline: a write is only answered once the server has it.
class _SlowCloud implements WalletSyncDataSource {
  final upload = Completer<String?>();

  @override
  Future<String?> syncWallet(WalletHiveModel wallet) => upload.future;

  @override
  Future<void> deleteWallet(String remoteId) => Completer<void>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SyncService implements FinancialDataSyncService {
  int requests = 0;

  @override
  Future<void> syncAll() async => requests++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletHiveModel _wallet(String name) => WalletHiveModel(
  id: 'w1',
  name: name,
  balance: 0,
  iconCode: 0,
  type: 'investment',
  createdAt: DateTime(2026),
  remoteId: 'w1',
);

void main() {
  late Directory dir;
  late _Local local;
  late _SlowCloud cloud;
  late _SyncService sync;
  late WalletRepositoryImpl repository;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('offline_changes');
    Hive.init(dir.path);
    await PrjAppStorage.register();
  });

  setUp(() async {
    await PendingCloudDeletes.clear();
    local = _Local();
    cloud = _SlowCloud();
    sync = _SyncService();
    repository = WalletRepositoryImpl(
      local: local,
      sync: cloud,
      syncService: sync,
      crashReporter: const CcNoopCrashReporter(),
    );
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('offline wallet delete returns and queues the cloud delete', () async {
    final result = await repository
        .deleteWallet('w1')
        .timeout(const Duration(seconds: 2));

    expect(result.isSuccess(), isTrue);
    expect(local.wallets, isEmpty);
    expect(PendingCloudDeletes.has('wallets', 'w1'), isTrue);
    expect(sync.requests, 1);
  });

  test('a wallet deleted while uploading does not come back', () async {
    final upload = repository.syncWallet('w1');
    await pumpEventQueue();
    await repository.deleteWallet('w1');

    cloud.upload.complete('w1');
    await upload;
    await pumpEventQueue();

    expect(local.wallets, isEmpty);
  });

  group('UploadWriteBack', () {
    late Box<String> box;

    setUp(() async {
      box = await Hive.openBox<String>('write_back');
      await box.clear();
    });

    Future<void> finishUpload(String sent) => UploadWriteBack.save<String>(
      box,
      'k',
      sent,
      mark: (current) => '$current synced',
      keepPending: (marked) => '$marked, still pending',
    );

    test('an untouched record is marked', () async {
      const sent = 'entry';
      await box.put('k', sent);
      await finishUpload(sent);

      expect(box.get('k'), 'entry synced');
    });

    test('a record changed meanwhile keeps the change, pending', () async {
      const sent = 'entry';
      await box.put('k', 'entry deleted');
      await finishUpload(sent);

      expect(box.get('k'), 'entry deleted synced, still pending');
    });

    test('a record removed meanwhile stays removed', () async {
      await finishUpload('entry');

      expect(box.containsKey('k'), isFalse);
    });
  });
}
