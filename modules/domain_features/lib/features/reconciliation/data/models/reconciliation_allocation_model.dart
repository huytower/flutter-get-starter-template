import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/reconciliation_allocation_entity.dart';

part 'reconciliation_allocation_model.g.dart';

@HiveType(typeId: CcHiveBox.RECONCILIATION_ALLOCATION_TYPE_ID)
class ReconciliationAllocationModel {
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final String walletName;

  @HiveField(2)
  final int bookBalance;

  @HiveField(3)
  final int actualBalance;

  ReconciliationAllocationModel({
    required this.walletId,
    required this.walletName,
    required this.bookBalance,
    required this.actualBalance,
  });

  factory ReconciliationAllocationModel.fromEntity(
    ReconciliationAllocationEntity entity,
  ) => ReconciliationAllocationModel(
    walletId: entity.walletId,
    walletName: entity.walletName,
    bookBalance: entity.bookBalance,
    actualBalance: entity.actualBalance,
  );

  ReconciliationAllocationEntity toEntity() => ReconciliationAllocationEntity(
    walletId: walletId,
    walletName: walletName,
    bookBalance: bookBalance,
    actualBalance: actualBalance,
  );

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'walletName': walletName,
      'bookBalance': bookBalance,
      'actualBalance': actualBalance,
    };
  }

  factory ReconciliationAllocationModel.fromJson(Map<String, dynamic> json) {
    return ReconciliationAllocationModel(
      walletId: json['walletId'] as String,
      walletName: json['walletName'] as String,
      bookBalance: json['bookBalance'] as int,
      actualBalance: json['actualBalance'] as int,
    );
  }
}
