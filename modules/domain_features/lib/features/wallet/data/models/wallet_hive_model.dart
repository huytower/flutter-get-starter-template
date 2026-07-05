import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/wallet_entity.dart';

part 'wallet_hive_model.g.dart';

@HiveType(typeId: CcHiveBox.WALLET_TYPE_ID)
class WalletHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int balance;

  @HiveField(3)
  final int iconCode;

  @HiveField(4)
  final String type;

  @HiveField(5)
  final DateTime createdAt;

  WalletHiveModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.type,
    required this.createdAt,
  });

  factory WalletHiveModel.fromEntity(WalletEntity entity) => WalletHiveModel(
    id: entity.id,
    name: entity.name,
    balance: entity.balance,
    iconCode: entity.iconCode,
    type: entity.type,
    createdAt: entity.createdAt,
  );

  WalletEntity toEntity() => WalletEntity(
    id: id,
    name: name,
    balance: balance,
    iconCode: iconCode,
    type: type,
    createdAt: createdAt,
  );
}
