import 'package:equatable/equatable.dart';

/// A saved "Fixed cost" quick-entry preset ("Mẫu nhanh") — e.g. "Đổ xăng
/// 50k" — that pre-fills the Expense form's category/amount/wallet in one
/// tap instead of the usual multi-step entry.
///
/// Expense-only for v1: every example in the spec ("Đổ xăng 50k", "Ăn cơm
/// trưa 35k") is a recurring expense, and templates only render on the
/// Expense tab.
class TransactionTemplateEntity extends Equatable {
  final String id;
  final String name;
  final int amount;

  /// FK to the [CategoryEntity] this template applies.
  final String categoryId;

  /// Denormalized category label/icon for chip display without a join.
  final String categoryLabel;
  final int? categoryIconCode;
  final String? categoryIconFamily;

  /// Wallet this template always applies to.
  final String walletId;

  const TransactionTemplateEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.categoryLabel,
    this.categoryIconCode,
    this.categoryIconFamily,
    required this.walletId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    categoryId,
    categoryLabel,
    categoryIconCode,
    categoryIconFamily,
    walletId,
  ];
}
