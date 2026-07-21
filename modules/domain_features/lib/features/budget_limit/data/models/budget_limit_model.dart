import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/budget_limit_entity.dart';

part 'budget_limit_model.g.dart';

/// Hive-persistable data model for [BudgetLimitEntity].
@HiveType(typeId: CcHiveBox.BUDGET_TYPE_ID)
class BudgetLimitModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int limit;

  // @HiveField(4) startDate and @HiveField(5) endDate were removed when
  // budgets became perpetual monthly — indices 4 and 5 are reserved, do not
  // reuse them.

  @HiveField(6)
  final int order;

  @HiveField(7)
  final bool isClosed;

  @HiveField(8)
  final bool isFixedPrice;

  @HiveField(9)
  final String? remoteId;

  @HiveField(10)
  final String? syncStatus;

  @HiveField(11)
  final DateTime? lastSyncedAt;

  @HiveField(12)
  final DateTime? lastModifiedAt;

  BudgetLimitModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.limit,
    required this.order,
    required this.isClosed,
    this.isFixedPrice = false,
    this.remoteId,
    this.syncStatus,
    this.lastSyncedAt,
    this.lastModifiedAt,
  });

  factory BudgetLimitModel.fromEntity(BudgetLimitEntity entity) =>
      BudgetLimitModel(
        id: entity.id,
        categoryId: entity.categoryId,
        name: entity.name,
        limit: entity.limit,
        order: entity.order,
        isClosed: entity.isClosed,
        isFixedPrice: entity.isFixedPrice,
      );

  BudgetLimitEntity toEntity() => BudgetLimitEntity(
    id: id,
    categoryId: categoryId,
    name: name,
    limit: limit,
    order: order,
    isClosed: isClosed,
    isFixedPrice: isFixedPrice,
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

  BudgetLimitModel copyWithSyncMetadata(SyncMetadata metadata) {
    return BudgetLimitModel(
      id: id,
      categoryId: categoryId,
      name: name,
      limit: limit,
      order: order,
      isClosed: isClosed,
      isFixedPrice: isFixedPrice,
      remoteId: metadata.remoteId,
      syncStatus: metadata.status.name,
      lastSyncedAt: metadata.lastSyncedAt,
      lastModifiedAt: metadata.lastModifiedAt,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'categoryId': categoryId,
      'name': name,
      'limit': limit,
      'order': order,
      'isClosed': isClosed,
      'isFixedPrice': isFixedPrice,
    };
  }

  factory BudgetLimitModel.fromFirestoreData(
    Map<String, dynamic> data,
    String localId,
  ) {
    final remoteModifiedAt = data['lastModifiedAt'] as String?;
    final parsedModifiedAt = remoteModifiedAt != null
        ? DateTime.tryParse(remoteModifiedAt)
        : null;

    return BudgetLimitModel(
      id: localId,
      categoryId: data['categoryId'] as String,
      name: data['name'] as String,
      limit: data['limit'] as int,
      order: data['order'] as int,
      isClosed: data['isClosed'] as bool,
      isFixedPrice: data['isFixedPrice'] as bool? ?? false,
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: parsedModifiedAt,
      lastModifiedAt: parsedModifiedAt,
    );
  }
}
