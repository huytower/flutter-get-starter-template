import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/wallet_entity.dart';

part 'wallet_hive_model.g.dart';

@HiveType(typeId: CcHiveBox.WALLET_TYPE_ID)
class WalletHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int balance;

  @HiveField(3)
  final int iconCode;

  @HiveField(4)
  final String type;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? remoteId;

  @HiveField(7)
  final String? syncStatus;

  @HiveField(8)
  final DateTime? lastSyncedAt;

  @HiveField(9)
  final DateTime? lastModifiedAt;

  @HiveField(10)
  final String? categoryId;

  WalletHiveModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.type,
    required this.createdAt,
    this.remoteId,
    this.syncStatus,
    this.lastSyncedAt,
    this.lastModifiedAt,
    this.categoryId,
  });

  factory WalletHiveModel.fromEntity(WalletEntity entity) => WalletHiveModel(
    id: entity.id,
    name: entity.name,
    balance: entity.balance,
    iconCode: entity.iconCode,
    type: entity.type,
    createdAt: entity.createdAt,
    categoryId: entity.categoryId,
  );

  WalletEntity toEntity() => WalletEntity(
    id: id,
    name: name,
    balance: balance,
    iconCode: iconCode,
    type: type,
    createdAt: createdAt,
    categoryId: categoryId,
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

  WalletHiveModel copyWithSyncMetadata(SyncMetadata metadata) {
    return WalletHiveModel(
      id: id,
      name: name,
      balance: balance,
      iconCode: iconCode,
      type: type,
      createdAt: createdAt,
      categoryId: categoryId,
      remoteId: metadata.remoteId,
      syncStatus: metadata.status.name,
      lastSyncedAt: metadata.lastSyncedAt,
      lastModifiedAt: metadata.lastModifiedAt,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'name': name,
      'balance': balance,
      'iconCode': iconCode,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  factory WalletHiveModel.fromFirestoreData(
    Map<String, dynamic> data,
    String localId,
  ) {
    return WalletHiveModel(
      id: localId,
      name: data['name'] as String,
      balance: data['balance'] as int,
      iconCode: data['iconCode'] as int,
      type: data['type'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: DateTime.now(),
      lastModifiedAt: DateTime.now(),
      categoryId: data['categoryId'] as String?,
    );
  }
}
