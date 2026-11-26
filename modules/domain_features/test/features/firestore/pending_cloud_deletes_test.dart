import 'dart:io';

import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:domain_features/core/data/sync/firestore_sync_service.dart';
import 'package:domain_features/features/firestore/pending_cloud_deletes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

class _Cloud implements FirestoreSyncService {
  _Cloud({this.failAfter});

  /// Throws (offline) once this many deletes went through; null = never.
  final int? failAfter;
  final List<String> deleted = [];

  @override
  Future<void> deleteFromFirestore({
    required String userId,
    required String collectionName,
    required String remoteId,
  }) async {
    if (failAfter != null && deleted.length >= failAfter!) {
      throw Exception('offline');
    }
    deleted.add('$collectionName/$remoteId');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('pending_cloud_deletes');
    Hive.init(dir.path);
    await PrjAppStorage.register();
  });

  setUp(PendingCloudDeletes.clear);

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('a queued delete blocks the pull and counts as pending', () async {
    await PendingCloudDeletes.add('budgets', ['b1', 'legacy-remote', null]);

    expect(PendingCloudDeletes.has('budgets', 'b1'), isTrue);
    expect(PendingCloudDeletes.has('budgets', 'legacy-remote'), isTrue);
    expect(PendingCloudDeletes.has('categories', 'b1'), isFalse);
    expect(PendingCloudDeletes.count, 2);
  });

  test(
    'online: flush deletes every queued document and empties the queue',
    () async {
      await PendingCloudDeletes.add('budgets', ['b1']);
      await PendingCloudDeletes.add('reconciliations', ['r1']);
      final cloud = _Cloud();

      await PendingCloudDeletes.flush(cloud, 'uid');

      expect(cloud.deleted, ['budgets/b1', 'reconciliations/r1']);
      expect(PendingCloudDeletes.count, 0);
    },
  );

  test('offline: what failed stays queued for the next sync', () async {
    await PendingCloudDeletes.add('loans', ['l1', 'l2']);

    await PendingCloudDeletes.flush(_Cloud(failAfter: 1), 'uid');

    expect(PendingCloudDeletes.count, 1);
    expect(PendingCloudDeletes.has('loans', 'l2'), isTrue);
  });

  test('clear forgets the queue (device changed owner)', () async {
    await PendingCloudDeletes.add('wallets', ['w1']);
    await PendingCloudDeletes.clear();

    expect(PendingCloudDeletes.count, 0);
  });
}
