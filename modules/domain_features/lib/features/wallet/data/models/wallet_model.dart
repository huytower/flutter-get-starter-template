import 'package:domain_features/export_domain_features.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  final String? id;
  final String? name;
  final double? balance;
  final int? iconCode;
  final String? type;
  final String? createdAt;

  WalletModel({
    this.id,
    this.name,
    this.balance,
    this.iconCode,
    this.type,
    this.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  WalletEntity toEntity() => WalletEntity(
    id: id ?? '',
    name: name ?? '',
    balance: balance ?? 0.0,
    iconCode: iconCode ?? 0,
    type: type ?? 'spending',
    createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
  );
}
