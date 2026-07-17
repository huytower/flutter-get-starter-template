import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
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

  BudgetLimitModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.limit,
    required this.order,
    required this.isClosed,
    this.isFixedPrice = false,
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
}
