import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/transaction_template_entity.dart';

part 'transaction_template_model.g.dart';

/// Hive-persistable data model for [TransactionTemplateEntity].
@HiveType(typeId: CcHiveBox.TRANSACTION_TEMPLATE_TYPE_ID)
class TransactionTemplateModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final String categoryLabel;

  @HiveField(5)
  final int? categoryIconCode;

  @HiveField(6)
  final String? categoryIconFamily;

  @HiveField(7)
  final String walletId;

  @HiveField(8)
  final String? remoteId;

  @HiveField(9)
  final String? syncStatus;

  @HiveField(10)
  final DateTime? lastSyncedAt;

  @HiveField(11)
  final DateTime? lastModifiedAt;

  TransactionTemplateModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.categoryLabel,
    this.categoryIconCode,
    this.categoryIconFamily,
    required this.walletId,
    this.remoteId,
    this.syncStatus,
    this.lastSyncedAt,
    this.lastModifiedAt,
  });

  factory TransactionTemplateModel.fromEntity(
    TransactionTemplateEntity entity,
  ) => TransactionTemplateModel(
    id: entity.id,
    name: entity.name,
    amount: entity.amount,
    categoryId: entity.categoryId,
    categoryLabel: entity.categoryLabel,
    categoryIconCode: entity.categoryIconCode,
    categoryIconFamily: entity.categoryIconFamily,
    walletId: entity.walletId,
  );

  TransactionTemplateEntity toEntity() => TransactionTemplateEntity(
    id: id,
    name: name,
    amount: amount,
    categoryId: categoryId,
    categoryLabel: categoryLabel,
    categoryIconCode: categoryIconCode,
    categoryIconFamily: categoryIconFamily,
    walletId: walletId,
  );

  SyncMetadata get syncMetadata => SyncMetadata(
    localId: id,
    remoteId: remoteId,
    status: syncStatus != null
        ? SyncStatus.values.firstWhere(
            (e) => e.name == syncStatus,
            orElse: () => SyncStatus.pending,
          )
        : SyncStatus.pending,
    lastSyncedAt: lastSyncedAt,
    lastModifiedAt: lastModifiedAt,
  );

  TransactionTemplateModel copyWithSyncMetadata(SyncMetadata metadata) {
    return TransactionTemplateModel(
      id: id,
      name: name,
      amount: amount,
      categoryId: categoryId,
      categoryLabel: categoryLabel,
      categoryIconCode: categoryIconCode,
      categoryIconFamily: categoryIconFamily,
      walletId: walletId,
      remoteId: metadata.remoteId,
      syncStatus: metadata.status.name,
      lastSyncedAt: metadata.lastSyncedAt,
      lastModifiedAt: metadata.lastModifiedAt,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'name': name,
      'amount': amount,
      'categoryId': categoryId,
      'categoryLabel': categoryLabel,
      'categoryIconCode': categoryIconCode,
      'categoryIconFamily': categoryIconFamily,
      'walletId': walletId,
    };
  }

  factory TransactionTemplateModel.fromFirestoreData(
    Map<String, dynamic> data,
    String localId,
  ) {
    final remoteModifiedAt = data['lastModifiedAt'] as String?;
    final parsedModifiedAt = remoteModifiedAt != null
        ? DateTime.tryParse(remoteModifiedAt)
        : null;

    return TransactionTemplateModel(
      id: localId,
      name: data['name'] as String,
      amount: data['amount'] as int,
      categoryId: data['categoryId'] as String,
      categoryLabel: data['categoryLabel'] as String,
      categoryIconCode: data['categoryIconCode'] as int?,
      categoryIconFamily: data['categoryIconFamily'] as String?,
      walletId: data['walletId'] as String,
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: parsedModifiedAt,
      lastModifiedAt: parsedModifiedAt,
    );
  }
}
