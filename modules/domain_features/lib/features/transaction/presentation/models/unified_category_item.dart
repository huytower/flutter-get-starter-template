import 'package:equatable/equatable.dart';

class UnifiedCategoryItem extends Equatable {
  final String id;
  final String? budgetId;
  final String categoryId;

  /// The localization key for the category name. If present, the UI will
  /// translate this key into the current language.
  final String? nameKey;

  /// A specific name provided by the user (for customized budgets). If
  /// present, this name will be shown as-is without translation.
  final String? customName;

  final int iconCode;
  final String? iconFamily;
  final DateTime lastActivityAt;
  final bool isBudget;

  /// The original order from the seed data, used as a secondary sort key
  /// when [lastActivityAt] is identical (e.g., first launch).
  final int initialOrder;

  const UnifiedCategoryItem({
    required this.id,
    this.budgetId,
    required this.categoryId,
    this.nameKey,
    this.customName,
    required this.iconCode,
    this.iconFamily,
    required this.lastActivityAt,
    this.isBudget = false,
    this.initialOrder = 999,
  });

  @override
  List<Object?> get props => [
    id,
    budgetId,
    categoryId,
    nameKey,
    customName,
    iconCode,
    iconFamily,
    lastActivityAt,
    isBudget,
    initialOrder,
  ];
}
