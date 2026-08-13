import 'package:equatable/equatable.dart';

/// Wallet type values stored in [WalletEntity.type].
///
/// `cash` is a singleton wallet with a fixed name/icon; `bank` and `credit`
/// are user-managed. (Legacy wallets stored as `'spending'` are migrated to
/// [bank] by the local datasource.)
abstract class WalletType {
  static const String cash = 'cash';
  static const String bank = 'bank';
  static const String ewallet = 'ewallet';
  static const String investment = 'investment';

  /// "Quỹ dự phòng" — a real, user-managed wallet like [bank]/[ewallet], but
  /// tracked in its own Budget Allocation hero banner (mirrors [investment])
  /// instead of the liquid-wallets strip. Its balance is user-entered
  /// directly (no formula), and it still counts as spendable cash for the
  /// Financial Runway calculation and as a normal wallet in Expense/Income
  /// pickers — only [investment] is excluded from those.
  static const String emergencyFund = 'emergency_fund';
}

class WalletEntity extends Equatable {
  final String id;
  final String name;
  final int balance;
  final int iconCode;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int displayOrder;

  /// FK to a [CategoryEntity] of type `investment` — classifies which
  /// investment category (Cổ phiếu, Kinh doanh cá nhân, ...) this wallet
  /// represents. Null for cash/bank/ewallet wallets.
  final String? categoryId;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.displayOrder = 0,
    this.categoryId,
  });

  WalletEntity copyWith({
    String? id,
    String? name,
    int? balance,
    int? iconCode,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? displayOrder,
    String? categoryId,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayOrder: displayOrder ?? this.displayOrder,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    balance,
    iconCode,
    type,
    createdAt,
    updatedAt,
    displayOrder,
    categoryId,
  ];
}
