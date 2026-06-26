import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';

/// A responsive container that adapts its padding, margin, and width
/// based on the current screen size (mobile, tablet, desktop).
///
/// Example usage:
/// ```dart
/// CcResponsiveContainer(
///   child: MyWidget(),
///   padding: EdgeInsets.all(16),
///   tabletPadding: EdgeInsets.all(24),
///   desktopPadding: EdgeInsets.all(32),
/// )
/// ```
class CcResponsiveContainer extends StatelessWidget {
  /// The child widget to display.
  final Widget child;

  /// Padding for mobile devices.
  final EdgeInsets? padding;

  /// Padding for tablet devices (optional, defaults to mobile).
  final EdgeInsets? tabletPadding;

  /// Padding for desktop devices (optional, defaults to tablet).
  final EdgeInsets? desktopPadding;

  /// Margin for mobile devices.
  final EdgeInsets? margin;

  /// Margin for tablet devices (optional, defaults to mobile).
  final EdgeInsets? tabletMargin;

  /// Margin for desktop devices (optional, defaults to tablet).
  final EdgeInsets? desktopMargin;

  /// Width for mobile devices (optional, defaults to full width).
  final double? width;

  /// Width for tablet devices (optional, defaults to 80% of screen).
  final double? tabletWidth;

  /// Width for desktop devices (optional, defaults to 60% of screen).
  final double? desktopWidth;

  /// Background color.
  final Color? color;

  /// Border radius.
  final BorderRadius? borderRadius;

  /// Box shadow.
  final List<BoxShadow>? boxShadow;

  /// Decoration.
  final Decoration? decoration;

  /// Alignment.
  final Alignment? alignment;

  /// Constraints.
  final BoxConstraints? constraints;

  const CcResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.tabletPadding,
    this.desktopPadding,
    this.margin,
    this.tabletMargin,
    this.desktopMargin,
    this.width,
    this.tabletWidth,
    this.desktopWidth,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.decoration,
    this.alignment,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final screenWidth = context.screenWidth;

    // Determine responsive padding
    EdgeInsets responsivePadding = padding ?? EdgeInsets.zero;
    if (screenType == ScreenType.tablet && tabletPadding != null) {
      responsivePadding = tabletPadding!;
    } else if (screenType == ScreenType.desktop && desktopPadding != null) {
      responsivePadding = desktopPadding!;
    } else if (screenType == ScreenType.desktop && tabletPadding != null) {
      responsivePadding = tabletPadding!;
    }

    // Determine responsive margin
    EdgeInsets responsiveMargin = margin ?? EdgeInsets.zero;
    if (screenType == ScreenType.tablet && tabletMargin != null) {
      responsiveMargin = tabletMargin!;
    } else if (screenType == ScreenType.desktop && desktopMargin != null) {
      responsiveMargin = desktopMargin!;
    } else if (screenType == ScreenType.desktop && tabletMargin != null) {
      responsiveMargin = tabletMargin!;
    }

    // Determine responsive width
    double? responsiveWidth = width;
    if (width == null) {
      if (screenType == ScreenType.tablet) {
        responsiveWidth = tabletWidth ?? screenWidth * 0.8;
      } else if (screenType == ScreenType.desktop) {
        responsiveWidth = desktopWidth ?? screenWidth * 0.6;
      }
    } else {
      if (screenType == ScreenType.tablet && tabletWidth != null) {
        responsiveWidth = tabletWidth;
      } else if (screenType == ScreenType.desktop && desktopWidth != null) {
        responsiveWidth = desktopWidth;
      }
    }

    return Container(
      padding: responsivePadding,
      margin: responsiveMargin,
      width: responsiveWidth,
      decoration:
          decoration ??
          BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            boxShadow: boxShadow,
          ),
      alignment: alignment,
      constraints: constraints,
      child: child,
    );
  }
}
