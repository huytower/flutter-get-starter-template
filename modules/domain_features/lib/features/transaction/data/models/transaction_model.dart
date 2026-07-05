import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: CcHiveBox.TRANSACTION_TYPE_ID)
@JsonSerializable()
class TransactionModel {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? type;

  @HiveField(2)
  final int? amount;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final String? date;

  @HiveField(6)
  final String? walletId;

  @HiveField(7)
  final String? categoryId;

  @HiveField(8)
  final String? budgetId;

  /// ISO-8601 timestamp; non-null marks the record as soft-deleted.
  @HiveField(9)
  final String? deletedAt;

  /// Links the two legs of a transfer; null for income/expense records.
  @HiveField(10)
  final String? transferId;

  TransactionModel({
    this.id,
    this.type,
    this.amount,
    this.category,
    this.note,
    this.date,
    this.walletId,
    this.categoryId,
    this.budgetId,
    this.deletedAt,
    this.transferId,
  });

  TransactionModel copyWith({String? deletedAt}) => TransactionModel(
    id: id,
    type: type,
    amount: amount,
    category: category,
    note: note,
    date: date,
    walletId: walletId,
    categoryId: categoryId,
    budgetId: budgetId,
    deletedAt: deletedAt ?? this.deletedAt,
    transferId: transferId,
  );

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  factory TransactionModel.fromEntity(TransactionEntity entity) =>
      TransactionModel(
        id: entity.id,
        type: entity.type,
        amount: entity.amount,
        category: entity.category,
        note: entity.note,
        date: entity.date.toIso8601String(),
        walletId: entity.walletId,
        categoryId: entity.categoryId,
        budgetId: entity.budgetId,
        deletedAt: entity.deletedAt?.toIso8601String(),
        transferId: entity.transferId,
      );

  TransactionEntity toEntity() => TransactionEntity(
    id: id ?? '',
    type: type ?? '',
    amount: amount ?? 0,
    category: category ?? '',
    categoryId: categoryId ?? '',
    budgetId: budgetId,
    note: note,
    date: date != null ? DateTime.parse(date!) : DateTime.now(),
    walletId: walletId ?? '',
    transferId: transferId,
    deletedAt: deletedAt != null ? DateTime.parse(deletedAt!) : null,
  );
}
