import 'dart:ui';

import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String nameKey;
  final int iconCode;
  final String? iconFamily;
  final Color? color;
  final String groupId;

  const CategoryEntity({
    required this.id,
    required this.nameKey,
    required this.iconCode,
    this.iconFamily,
    this.color,
    required this.groupId,
  });

  @override
  List<Object?> get props => [
    id,
    nameKey,
    iconCode,
    iconFamily,
    color,
    groupId,
  ];
}
