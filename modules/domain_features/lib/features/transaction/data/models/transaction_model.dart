import 'package:domain_features/export_domain_features.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final String? id;
  final String? type;
  final double? amount;
  final String? category;
  final String? note;
  final String? date;
  final String? walletId;

  TransactionModel({
    this.id,
    this.type,
    this.amount,
    this.category,
    this.note,
    this.date,
    this.walletId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  TransactionEntity toEntity() => TransactionEntity(
    id: id ?? '',
    type: type ?? '',
    amount: amount ?? 0.0,
    category: category ?? '',
    note: note,
    date: date != null ? DateTime.parse(date!) : DateTime.now(),
    walletId: walletId ?? '',
  );
}
