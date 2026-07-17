import 'package:equatable/equatable.dart';

/// A perpetual monthly spending budget for a category ("Ngân sách").
///
/// Adapted from the web `NganSach` model, but the category is split out:
/// a budget references a [categoryId] instead of being the category itself.
/// A budget has no start/end dates — it exists continuously once created and
/// its spend is computed per calendar month (1st → end of month).
class BudgetLimitEntity extends Equatable {
  final String id;

  /// FK to the [CategoryEntity] this budget caps.
  final String categoryId;

  /// Display name ("ten_ngan_sach").
  final String name;

  /// Monthly spending limit ("dinh_muc").
  final int limit;

  /// Display order ("thu_tu").
  final int order;

  /// Soft-deleted/archived budgets are hidden but kept in storage.
  final bool isClosed;

  /// True if the budget has a fixed price/cost.
  final bool isFixedPrice;

  const BudgetLimitEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.limit,
    this.order = 0,
    this.isClosed = false,
    this.isFixedPrice = false,
  });

  BudgetLimitEntity copyWith({
    String? id,
    String? categoryId,
    String? name,
    int? limit,
    int? order,
    bool? isClosed,
    bool? isFixedPrice,
  }) {
    return BudgetLimitEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      limit: limit ?? this.limit,
      order: order ?? this.order,
      isClosed: isClosed ?? this.isClosed,
      isFixedPrice: isFixedPrice ?? this.isFixedPrice,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    limit,
    order,
    isClosed,
    isFixedPrice,
  ];
}
