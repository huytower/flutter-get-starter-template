import 'package:flutter/material.dart';

import '../../../export_cc_sdk_ui.dart';

/// Extension for responsive UI calculations
extension ResponsiveExtension on BuildContext {
  /// Get responsive icon size based on screen width
  /// Base size: 24px for mobile, scales up to 32px for larger screens
  ///
  /// Formula: baseSize * (screenWidth / baselineWidth).clamp(1.0, maxMultiplier)
  ///
  /// Example usage:
  /// ```dart
  /// final iconSize = context.respIconSize();
  /// ```
  double respIconSize({
    double baseSize = 24.0,
    double baselineWidth = 360.0,
    double maxMultiplier = 1.5,
  }) {
    return baseSize * (screenWidth / baselineWidth).clamp(1.0, maxMultiplier);
  }

  /// Get responsive font size based on screen width
  /// Base size scales up to 1.33x on larger screens
  ///
  /// Example usage:
  /// ```dart
  /// final fontSize = context.respFontSize(16.0);
  /// ```
  double respFontSize(
    double baseSize, {
    double baselineWidth = 360.0,
    double maxMultiplier = 1.5,
  }) {
    return baseSize * (screenWidth / baselineWidth).clamp(1.0, maxMultiplier);
  }

  /// Get responsive padding based on screen width
  /// Base padding scales up to 1.5x on larger screens
  ///
  /// Example usage:
  /// ```dart
  /// final padding = context.respPadding(16.0);
  /// ```
  double respPadding(
    double basePadding, {
    double baselineWidth = 360.0,
    double maxMultiplier = 1.5,
  }) {
    return basePadding *
        (screenWidth / baselineWidth).clamp(1.0, maxMultiplier);
  }

  /// Get responsive dimension (width/height) based on screen width
  ///
  /// Example usage:
  /// ```dart
  /// final width = context.respDim(4.0);
  /// ```
  double respDim(
    double baseDimension, {
    double baselineWidth = 360.0,
    double maxMultiplier = 1.5,
  }) {
    return baseDimension *
        (screenWidth / baselineWidth).clamp(1.0, maxMultiplier);
  }
}
