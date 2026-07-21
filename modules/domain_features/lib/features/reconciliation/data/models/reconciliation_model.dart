import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/reconciliation_entity.dart';
import 'reconciliation_allocation_model.dart';

part 'reconciliation_model.g.dart';

@HiveType(typeId: CcHiveBox.RECONCILIATION_TYPE_ID)
class ReconciliationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int year;

  @HiveField(2)
  final int week;

  @HiveField(3)
  final int systemTotal;

  @HiveField(4)
  final int actualTotal;

  @HiveField(5)
  final int difference;

  @HiveField(6)
  final String date;

  @HiveField(7)
  final List<String> adjustmentTransactionIds;

  @HiveField(8)
  final List<ReconciliationAllocationModel> allocations;

  @HiveField(9)
  final String? remoteId;

  @HiveField(10)
  final String? syncStatus;

  @HiveField(11)
  final DateTime? lastSyncedAt;

  @HiveField(12)
  final DateTime? lastModifiedAt;

  ReconciliationModel({
    required this.id,
    required this.year,
    required this.week,
    required this.systemTotal,
    required this.actualTotal,
    required this.difference,
    required this.date,
    required this.adjustmentTransactionIds,
    required this.allocations,
    this.remoteId,
    this.syncStatus,
    this.lastSyncedAt,
    this.lastModifiedAt,
  });

  factory ReconciliationModel.fromEntity(ReconciliationEntity entity) =>
      ReconciliationModel(
        id: entity.id,
        year: entity.year,
        week: entity.week,
        systemTotal: entity.systemTotal,
        actualTotal: entity.actualTotal,
        difference: entity.difference,
        date: entity.date.toIso8601String(),
        adjustmentTransactionIds: entity.adjustmentTransactionIds,
        allocations: entity.allocations
            .map(ReconciliationAllocationModel.fromEntity)
            .toList(),
      );

  ReconciliationEntity toEntity() => ReconciliationEntity(
    id: id,
    year: year,
    week: week,
    systemTotal: systemTotal,
    actualTotal: actualTotal,
    difference: difference,
    date: DateTime.parse(date),
    adjustmentTransactionIds: adjustmentTransactionIds,
    allocations: allocations.map((a) => a.toEntity()).toList(),
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

  ReconciliationModel copyWithSyncMetadata(SyncMetadata metadata) {
    return ReconciliationModel(
      id: id,
      year: year,
      week: week,
      systemTotal: systemTotal,
      actualTotal: actualTotal,
      difference: difference,
      date: date,
      adjustmentTransactionIds: adjustmentTransactionIds,
      allocations: allocations,
      remoteId: metadata.remoteId,
      syncStatus: metadata.status.name,
      lastSyncedAt: metadata.lastSyncedAt,
      lastModifiedAt: metadata.lastModifiedAt,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'year': year,
      'week': week,
      'systemTotal': systemTotal,
      'actualTotal': actualTotal,
      'difference': difference,
      'date': date,
      'adjustmentTransactionIds': adjustmentTransactionIds,
      'allocations': allocations.map((a) => a.toJson()).toList(),
    };
  }

  factory ReconciliationModel.fromFirestoreData(
    Map<String, dynamic> data,
    String localId,
  ) {
    final remoteModifiedAt = data['lastModifiedAt'] as String?;
    final parsedModifiedAt = remoteModifiedAt != null
        ? DateTime.tryParse(remoteModifiedAt)
        : null;

    return ReconciliationModel(
      id: localId,
      year: data['year'] as int,
      week: data['week'] as int,
      systemTotal: data['systemTotal'] as int,
      actualTotal: data['actualTotal'] as int,
      difference: data['difference'] as int,
      date: data['date'] as String,
      adjustmentTransactionIds: List<String>.from(
        data['adjustmentTransactionIds'] as List? ?? [],
      ),
      allocations: (data['allocations'] as List? ?? [])
          .map(
            (a) => ReconciliationAllocationModel.fromJson(
              a as Map<String, dynamic>,
            ),
          )
          .toList(),
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: parsedModifiedAt,
      lastModifiedAt: parsedModifiedAt,
    );
  }
}
