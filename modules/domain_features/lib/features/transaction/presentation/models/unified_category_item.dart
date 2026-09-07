import 'package:equatable/equatable.dart';

class UnifiedCategoryItem extends Equatable {
  final String id;
  final String? budgetId;
  final String categoryId;
  final String displayName;
  final int iconCode;
  final String? iconFamily;
  final DateTime lastActivityAt;
  final bool isBudget;

  const UnifiedCategoryItem({
    required this.id,
    this.budgetId,
    required this.categoryId,
    required this.displayName,
    required this.iconCode,
    this.iconFamily,
    required this.lastActivityAt,
    this.isBudget = false,
  });

  @override
  List<Object?> get props => [
    id,
    budgetId,
    categoryId,
    displayName,
    iconCode,
    iconFamily,
    lastActivityAt,
    isBudget,
  ];
}
