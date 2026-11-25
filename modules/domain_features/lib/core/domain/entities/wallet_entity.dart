import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:equatable/equatable.dart';

export 'wallet_type.dart';

class WalletEntity extends Equatable {
  final String id;
  final String name;
  final int balance;
  final int iconCode;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int displayOrder;
  final String currencyCode;

  /// FK to a [CategoryEntity] of type `investment` — classifies which
  /// investment category (Cổ phiếu, Kinh doanh cá nhân, ...) this wallet
  /// represents. Null for cash/bank/ewallet wallets.
  final String? categoryId;

  /// Localization key for the category name.
  final String? categoryNameKey;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.displayOrder = 0,
    this.currencyCode = CurrencyConstants.defaultCurrencyCode,
    this.categoryId,
    this.categoryNameKey,
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
    String? currencyCode,
    String? categoryId,
    String? categoryNameKey,
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
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      categoryNameKey: categoryNameKey ?? this.categoryNameKey,
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
    currencyCode,
    categoryId,
    categoryNameKey,
  ];
}
