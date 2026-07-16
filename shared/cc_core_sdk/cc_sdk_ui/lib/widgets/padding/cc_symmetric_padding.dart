import 'package:flutter/material.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';

/// Reusable symmetric padding widget.
///
/// Encapsulates [EdgeInsets.symmetric] with responsive base values so the
/// common `context.respDim(n)` symmetric padding idiom is not duplicated
/// across features. Base values are scaled via [BuildContext.respDim].
///
/// Example:
/// ```dart
/// CcSymmetricPadding(
///   horizontal: 16,
///   vertical: 16,
///   child: child,
/// );
/// ```
class CcSymmetricPadding extends StatelessWidget {
  const CcSymmetricPadding({
    super.key,
    required this.child,
    this.horizontal = 0,
    this.vertical = 0,
  });

  final Widget child;
  final double horizontal;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respDim(horizontal),
        vertical: context.respDim(vertical),
      ),
      child: child,
    );
  }
}
