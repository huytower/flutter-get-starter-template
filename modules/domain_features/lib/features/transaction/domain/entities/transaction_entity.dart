import 'package:equatable/equatable.dart';

/// Discriminators stored in [TransactionEntity.type].
///
/// A transfer ("Chuyển khoản") is stored as two linked legs: a [transferOut]
/// on the source wallet and a [transferIn] on the destination, sharing a
/// [TransactionEntity.transferId]. Transfers are excluded from income/expense
/// reports and history — they only move money between wallets.
abstract class TransactionType {
  static const String income = 'income';
  static const String expense = 'expense';
  static const String transferOut = 'transfer_out';
  static const String transferIn = 'transfer_in';
}

class TransactionEntity extends Equatable {
  final String id;
  final String type;
  final int amount;

  /// Human-readable category label (denormalized for display).
  final String category;

  /// FK to the owning [CategoryEntity] (used for budget aggregation).
  final String categoryId;

  /// FK to the [BudgetEntity] this expense counts against (nullable).
  final String? budgetId;

  final String? note;
  final DateTime date;
  final String walletId;

  /// Links the two legs of a transfer. Null for income/expense records.
  final String? transferId;

  /// When non-null the record is soft-deleted and excluded from all reads.
  final DateTime? deletedAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.categoryId = '',
    this.budgetId,
    this.note,
    required this.date,
    required this.walletId,
    this.transferId,
    this.deletedAt,
  });

  /// True for either leg of a transfer.
  bool get isTransfer =>
      type == TransactionType.transferOut ||
      type == TransactionType.transferIn;

  bool get isDeleted => deletedAt != null;

  TransactionEntity copyWith({
    String? id,
    String? type,
    int? amount,
    String? category,
    String? categoryId,
    String? budgetId,
    String? note,
    DateTime? date,
    String? walletId,
    String? transferId,
    DateTime? deletedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      note: note ?? this.note,
      date: date ?? this.date,
      walletId: walletId ?? this.walletId,
      transferId: transferId ?? this.transferId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    category,
    categoryId,
    budgetId,
    note,
    date,
    walletId,
    transferId,
    deletedAt,
  ];
}
