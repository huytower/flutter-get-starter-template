import 'package:equatable/equatable.dart';

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
