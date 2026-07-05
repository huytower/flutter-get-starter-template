import 'package:equatable/equatable.dart';

/// A spending budget for a category over a time period ("Ngân sách").
///
/// Adapted from the web `NganSach` model, but the category is split out:
/// a budget references a [categoryId] instead of being the category itself.
class BudgetEntity extends Equatable {
  final String id;

  /// FK to the [CategoryEntity] this budget caps.
  final String categoryId;

  /// Display name ("ten_ngan_sach").
  final String name;

  /// Spending limit ("dinh_muc").
  final int limit;

  final DateTime startDate;
  final DateTime endDate;

  /// Display order ("thu_tu"); preserved across resets.
  final int order;

  /// Closed budgets are archived after a reconciliation/reset
  /// ("trang_thai_xac_thuc").
  final bool isClosed;

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.limit,
    required this.startDate,
    required this.endDate,
    this.order = 0,
    this.isClosed = false,
  });

  /// Whether [date] falls within this budget's period (inclusive).
  bool containsDate(DateTime date) =>
      !date.isBefore(startDate) && !date.isAfter(endDate);

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    String? name,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    int? order,
    bool? isClosed,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      limit: limit ?? this.limit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      order: order ?? this.order,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    limit,
    startDate,
    endDate,
    order,
    isClosed,
  ];
}
