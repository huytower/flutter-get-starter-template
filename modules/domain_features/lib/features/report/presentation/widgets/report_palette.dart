import 'package:flutter/material.dart';

import '../../domain/entities/category_spending_entity.dart';

/// Fallback slice colours for categories that don't define their own, keyed by
/// position so the pie and its legend stay in sync.
const List<Color> kReportPalette = [
  Color(0xFF5B8DEF), // blue
  Color(0xFFEF6C6C), // red
  Color(0xFFF2A65A), // orange
  Color(0xFF57C784), // green
  Color(0xFF9B7EDE), // purple
  Color(0xFF4BC0C8), // teal
  Color(0xFFE86AA6), // pink
  Color(0xFFB0B95A), // olive
];

/// The colour to draw [slice] with — its own colour when set, otherwise a
/// deterministic palette entry for its [index].
Color reportSliceColor(CategorySpendingEntity slice, int index) {
  return slice.color ?? kReportPalette[index % kReportPalette.length];
}
