import 'dart:ui';

import 'package:equatable/equatable.dart';

/// Category kind stored in [CategoryEntity.type].
abstract class CategoryType {
  static const String expense = 'expense';
  static const String income = 'income';
  static const String liability = 'debt_loan';
  static const String investment = 'investment';
}

class CategoryEntity extends Equatable {
  final String id;
  final String nameKey;
  final int iconCode;
  final String? iconFamily;
  final Color? color;
  final String groupId;
  final bool hasEnabled;

  /// [CategoryType.expense] or [CategoryType.income].
  final String type;

  const CategoryEntity({
    required this.id,
    required this.nameKey,
    required this.iconCode,
    this.iconFamily,
    this.color,
    required this.groupId,
    this.hasEnabled = true,
    this.type = CategoryType.expense,
  });

  CategoryEntity copyWith({
    String? nameKey,
    int? iconCode,
    String? iconFamily,
    Color? color,
    String? groupId,
    bool? hasEnabled,
    String? type,
  }) => CategoryEntity(
    id: id,
    nameKey: nameKey ?? this.nameKey,
    iconCode: iconCode ?? this.iconCode,
    iconFamily: iconFamily ?? this.iconFamily,
    color: color ?? this.color,
    groupId: groupId ?? this.groupId,
    hasEnabled: hasEnabled ?? this.hasEnabled,
    type: type ?? this.type,
  );

  @override
  List<Object?> get props => [
    id,
    nameKey,
    iconCode,
    iconFamily,
    color,
    groupId,
    hasEnabled,
    type,
  ];
}
