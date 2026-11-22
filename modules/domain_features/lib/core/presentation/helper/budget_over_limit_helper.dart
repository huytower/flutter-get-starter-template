import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

/// Text-color severity tier for the over-limit counter snackbar:
/// 1–5 lần → green, 6–10 lần → amber, 11+ lần → red (uncapped).
Color budgetOverLimitColor(int count, ColorScheme scheme) {
  if (count <= 5) return PrjColors.success;
  if (count <= 10) return PrjColors.warning;
  return scheme.error;
}
