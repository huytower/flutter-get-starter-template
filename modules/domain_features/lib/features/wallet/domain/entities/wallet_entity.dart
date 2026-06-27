import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';

part 'wallet_entity.g.dart';

@HiveType(typeId: CcHiveBox.WALLET_TYPE_ID)
class WalletEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double balance;

  @HiveField(3)
  final int iconCode;

  @HiveField(4)
  final String type;

  @HiveField(5)
  final DateTime createdAt;

  WalletEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.type,
    required this.createdAt,
  });
}
