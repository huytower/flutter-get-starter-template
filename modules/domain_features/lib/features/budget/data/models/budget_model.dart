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

  // @HiveField(4) startDate and @HiveField(5) endDate were removed when
  // budgets became perpetual monthly — indices 4 and 5 are reserved, do not
  // reuse them.

  @HiveField(6)
  final int order;

  @HiveField(7)
  final bool isClosed;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.limit,
    required this.order,
    required this.isClosed,
  });

  factory BudgetModel.fromEntity(BudgetEntity entity) => BudgetModel(
    id: entity.id,
    categoryId: entity.categoryId,
    name: entity.name,
    limit: entity.limit,
    order: entity.order,
    isClosed: entity.isClosed,
  );

  BudgetEntity toEntity() => BudgetEntity(
    id: id,
    categoryId: categoryId,
    name: name,
    limit: limit,
    order: order,
    isClosed: isClosed,
  );
}
