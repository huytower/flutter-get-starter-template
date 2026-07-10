import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
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
}
