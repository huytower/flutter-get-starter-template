import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/wallet_entity.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  final String? id;
  final String? name;
  final int? balance;
  final int? iconCode;
  final String? type;
  final String? createdAt;
  final String? updatedAt;
  final int? displayOrder;

  WalletModel({
    this.id,
    this.name,
    this.balance,
    this.iconCode,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.displayOrder,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  WalletEntity toEntity() => WalletEntity(
    id: id ?? '',
    name: name ?? '',
    balance: balance ?? 0,
    iconCode: iconCode ?? 0,
    type: type ?? 'spending',
    createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
    updatedAt: updatedAt != null
        ? DateTime.parse(updatedAt!)
        : (createdAt != null ? DateTime.parse(createdAt!) : DateTime.now()),
    displayOrder: displayOrder ?? 0,
  );
}
