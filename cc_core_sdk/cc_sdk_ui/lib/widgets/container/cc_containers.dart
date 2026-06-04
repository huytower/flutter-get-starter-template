import 'package:flutter/material.dart';

import '../../core/helper/cc_widget_helper.dart';

/// A circular container with optional shadow and border.
class CcContainerCircle extends StatelessWidget {
  final Widget? child;
  final bool hasShadow;
  final Color bgColor;
  final Color shadowColor;
  final Color strokeColor;
  final double strokeWidth;
  final double width;

  const CcContainerCircle({
    super.key,
    this.child,
    this.bgColor = Colors.transparent,
    this.hasShadow = false,
    this.shadowColor = Colors.transparent,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 0.0,
    this.width = 28.0,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: width,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: bgColor,
      border: Border.all(color: strokeColor, width: strokeWidth),
      boxShadow: hasShadow
          ? CcWidgetHelper.getBoxShadows(context, shadowColor: shadowColor)
          : const [],
    ),
    child: child ?? const SizedBox(),
  );
}

/// A rectangular container with small rounded corners.
class CcContainerRect extends StatelessWidget {
  final Widget child;
  final Color bgColor;
  final double width;
  final double height;

  const CcContainerRect({
    super.key,
    required this.bgColor,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: CcWidgetHelper.getBorderRoundedSM(),
    ),
    width: width,
    height: height,
    child: child,
  );
}

/// A square container with small rounded corners.
class CcContainerSquare extends StatelessWidget {
  final Widget child;
  final Color bgColor;
  final double width;

  const CcContainerSquare({
    super.key,
    required this.bgColor,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: CcWidgetHelper.getBorderRoundedSM(),
    ),
    width: width,
    height: width,
    child: child,
  );
}
