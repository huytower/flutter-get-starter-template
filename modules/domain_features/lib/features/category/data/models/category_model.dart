import 'dart:ui';

import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
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

  CategoryModel({
    required this.id,
    required this.nameKey,
    required this.iconCode,
    this.iconFamily,
    this.colorValue,
    required this.groupId,
    this.isEnabled = true,
    this.type = CategoryType.expense,
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
}
