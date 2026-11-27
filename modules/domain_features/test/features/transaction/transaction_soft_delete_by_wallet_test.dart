import 'dart:io';

import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/models/sync_metadata.dart';
import 'package:domain_features/features/transaction/data/datasources/local/transaction_local_datasource.dart';
import 'package:domain_features/features/transaction/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

/// Deleting an investment position soft-deletes its entries on every wallet
/// and flags them for sync, so a pull can't bring them back.
void main() {
  late Directory dir;
  final dataSource = TransactionLocalDataSource();

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('soft_delete_by_wallet');
    Hive.init(dir.path);
    Hive.registerAdapter(TransactionModelAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  TransactionModel synced(
    String id,
    String type,
    String walletId, {
    String? position,
  }) {
    final model = TransactionModel.fromEntity(
      TransactionEntity(
        id: id,
        type: type,
        amount: 500000,
        category: 'Stocks',
        date: DateTime(2026, 11, 27),
        walletId: walletId,
        investmentWalletId: position,
      ),
    );
    return model.copyWithSyncMetadata(
      SyncMetadata.synced(localId: id, remoteId: id),
    );
  }

  test('marks every linked entry deleted and pending sync', () async {
    await dataSource.add(
      synced('out', TransactionType.investmentOut, 'cash', position: 'vcb'),
    );
    await dataSource.add(
      synced('in', TransactionType.investmentIn, 'vcb', position: 'vcb'),
    );
    await dataSource.add(
      synced('ret', TransactionType.investmentReturn, 'cash', position: 'vcb'),
    );
    await dataSource.add(synced('food', TransactionType.expense, 'cash'));

    await dataSource.softDeleteByWallet('vcb', DateTime(2026, 11, 28));

    for (final id in ['out', 'in', 'ret']) {
      final model = (await dataSource.getById(id))!;
      expect(model.deletedAt, isNotNull, reason: id);
      expect(model.syncMetadata.status, SyncStatus.pending, reason: id);
    }
    final untouched = (await dataSource.getById('food'))!;
    expect(untouched.deletedAt, isNull);
    expect(untouched.syncMetadata.status, SyncStatus.synced);
  });
}
