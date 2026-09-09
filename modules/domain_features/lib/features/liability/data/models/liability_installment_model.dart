import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/liability_entity.dart';

part 'liability_installment_model.g.dart';

/// Embedded (not its own box) — always read/written as part of a
/// [LiabilityModel]'s `installments` list, mirrors
/// `ReconciliationAllocationModel`.
@HiveType(typeId: CcHiveBox.LIABILITY_INSTALLMENT_TYPE_ID)
class LiabilityInstallmentModel {
  @HiveField(0)
  final String dueDate;

  @HiveField(1)
  final int amount;

  LiabilityInstallmentModel({required this.dueDate, required this.amount});

  factory LiabilityInstallmentModel.fromEntity(
    LiabilityInstallmentEntity entity,
  ) => LiabilityInstallmentModel(
    dueDate: entity.dueDate.toIso8601String(),
    amount: entity.amount,
  );

  LiabilityInstallmentEntity toEntity() => LiabilityInstallmentEntity(
    dueDate: DateTime.parse(dueDate),
    amount: amount,
  );

  Map<String, dynamic> toJson() {
    return {'dueDate': dueDate, 'amount': amount};
  }

  factory LiabilityInstallmentModel.fromJson(Map<String, dynamic> json) {
    return LiabilityInstallmentModel(
      dueDate: json['dueDate'] as String,
      amount: json['amount'] as int,
    );
  }
}
