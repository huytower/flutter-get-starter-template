import 'dart:ui';

import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String nameKey;
  final int iconCode;
  final String? iconFamily;
  final Color? color;
  final String groupId;
  final bool isEnabled;

  const CategoryEntity({
    required this.id,
    required this.nameKey,
    required this.iconCode,
    this.iconFamily,
    this.color,
    required this.groupId,
    this.isEnabled = true,
  });

  CategoryEntity copyWith({bool? isEnabled}) => CategoryEntity(
    id: id,
    nameKey: nameKey,
    iconCode: iconCode,
    iconFamily: iconFamily,
    color: color,
    groupId: groupId,
    isEnabled: isEnabled ?? this.isEnabled,
  );

  @override
  List<Object?> get props => [
    id,
    nameKey,
    iconCode,
    iconFamily,
    color,
    groupId,
    isEnabled,
  ];
}
