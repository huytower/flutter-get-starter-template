import 'dart:ui';
import 'package:equatable/equatable.dart';

/// One slice of the spending pie ("tỷ trọng chi tiêu"): the total expense in a
/// category over the report range, plus its share of the grand total.
class CategorySpendingEntity extends Equatable {
  final String categoryId;

  /// Category display key (resolve with `el.tr`).
  final String nameKey;

  final int iconCode;
  final String? iconFamily;

  /// Category's own colour when set.
  final Color? color;

  /// Total spent in this category over the range.
  final int amount;

  /// Share of the range's total expense, in 0..1.
  final double fraction;

  const CategorySpendingEntity({
    required this.categoryId,
    required this.nameKey,
    required this.iconCode,
    this.iconFamily,
    this.color,
    required this.amount,
    required this.fraction,
  });

  /// Whole-percent share for labels (e.g. `42`).
  int get percent => (fraction * 100).round();

  @override
  List<Object?> get props => [categoryId, amount, fraction, nameKey, iconCode, iconFamily, color];
}
