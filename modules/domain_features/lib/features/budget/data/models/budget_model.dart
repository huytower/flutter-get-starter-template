import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/budget_entity.dart';

part 'budget_model.g.dart';

/// Hive-persistable data model for [BudgetEntity].
@HiveType(typeId: CcHiveBox.BUDGET_TYPE_ID)
class BudgetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int limit;

  @HiveField(4)
  final String startDate;

  @HiveField(5)
  final String endDate;

  @HiveField(6)
  final int order;

  @HiveField(7)
  final bool isClosed;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.limit,
    required this.startDate,
    required this.endDate,
    required this.order,
    required this.isClosed,
  });

  factory BudgetModel.fromEntity(BudgetEntity entity) => BudgetModel(
    id: entity.id,
    categoryId: entity.categoryId,
    name: entity.name,
    limit: entity.limit,
    startDate: entity.startDate.toIso8601String(),
    endDate: entity.endDate.toIso8601String(),
    order: entity.order,
    isClosed: entity.isClosed,
  );

  BudgetEntity toEntity() => BudgetEntity(
    id: id,
    categoryId: categoryId,
    name: name,
    limit: limit,
    startDate: DateTime.parse(startDate),
    endDate: DateTime.parse(endDate),
    order: order,
    isClosed: isClosed,
  );
}
