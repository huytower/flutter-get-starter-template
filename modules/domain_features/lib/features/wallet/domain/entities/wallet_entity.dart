import 'package:equatable/equatable.dart';

/// Wallet type values stored in [WalletEntity.type].
///
/// `cash` is a singleton wallet with a fixed name/icon; `bank` and `credit`
/// are user-managed. (Legacy wallets stored as `'spending'` are migrated to
/// [bank] by the local datasource.)
abstract class WalletType {
  static const String cash = 'cash';
  static const String bank = 'bank';
  static const String credit = 'credit';
}

class WalletEntity extends Equatable {
  final String id;
  final String name;
  final int balance;
  final int iconCode;
  final String type;
  final DateTime createdAt;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, balance, iconCode, type, createdAt];
}
