import 'dart:ui';

import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

/// Hive-persistable data model for [CategoryEntity].
///
/// Keeps the domain entity pure: the `Color` field is stored as a primitive
/// ARGB int (`colorValue`) so Hive can serialize it without a custom adapter.
@HiveType(typeId: CcHiveBox.CATEGORY_TYPE_ID)
class CategoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameKey;

  @HiveField(2)
  final int iconCode;

  @HiveField(3)
  final String? iconFamily;

  @HiveField(4)
  final int? colorValue;

  @HiveField(5)
  final String groupId;

  @HiveField(6)
  final bool isEnabled;

  /// Nullable for records written before the field existed — read back as
  /// [CategoryType.expense].
  @HiveField(7)
  final String? type;

  @HiveField(8)
  final String? remoteId;

  @HiveField(9)
  final String? syncStatus;

  @HiveField(10)
  final DateTime? lastSyncedAt;

  @HiveField(11)
  final DateTime? lastModifiedAt;

  CategoryModel({
    required this.id,
    required this.nameKey,
    required this.iconCode,
    this.iconFamily,
    this.colorValue,
    required this.groupId,
    this.isEnabled = true,
    this.type = CategoryType.expense,
    this.remoteId,
    this.syncStatus,
    this.lastSyncedAt,
    this.lastModifiedAt,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) => CategoryModel(
    id: entity.id,
    nameKey: entity.nameKey,
    iconCode: entity.iconCode,
    iconFamily: entity.iconFamily,
    colorValue: entity.color?.toARGB32(),
    groupId: entity.groupId,
    isEnabled: entity.isEnabled,
    type: entity.type,
  );

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    nameKey: nameKey,
    iconCode: iconCode,
    iconFamily: iconFamily,
    color: colorValue != null ? Color(colorValue!) : null,
    groupId: groupId,
    isEnabled: isEnabled,
    type: type ?? CategoryType.expense,
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

  CategoryModel copyWithSyncMetadata(SyncMetadata metadata) {
    return CategoryModel(
      id: id,
      nameKey: nameKey,
      iconCode: iconCode,
      iconFamily: iconFamily,
      colorValue: colorValue,
      groupId: groupId,
      isEnabled: isEnabled,
      type: type,
      remoteId: metadata.remoteId,
      syncStatus: metadata.status.name,
      lastSyncedAt: metadata.lastSyncedAt,
      lastModifiedAt: metadata.lastModifiedAt,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'nameKey': nameKey,
      'iconCode': iconCode,
      'iconFamily': iconFamily,
      'colorValue': colorValue,
      'groupId': groupId,
      'isEnabled': isEnabled,
      'type': type,
    };
  }

  factory CategoryModel.fromFirestoreData(
    Map<String, dynamic> data,
    String localId,
  ) {
    final remoteModifiedAt = data['lastModifiedAt'] as String?;
    final parsedModifiedAt = remoteModifiedAt != null
        ? DateTime.tryParse(remoteModifiedAt)
        : null;

    return CategoryModel(
      id: localId,
      nameKey: data['nameKey'] as String,
      iconCode: data['iconCode'] as int,
      iconFamily: data['iconFamily'] as String?,
      colorValue: data['colorValue'] as int?,
      groupId: data['groupId'] as String,
      isEnabled: data['isEnabled'] as bool? ?? true,
      type: data['type'] as String? ?? CategoryType.expense,
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: parsedModifiedAt,
      lastModifiedAt: parsedModifiedAt,
    );
  }
}
