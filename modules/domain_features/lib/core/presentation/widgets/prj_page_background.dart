import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Standard page background: the faint brand gradient first used on the
/// Profile page, painted behind [child].
///
/// Every `CcGetView` page gets it by default (see
/// `CcGetView.onPageBodyWrapper`); pages built on `CcViewConfigMixin` directly
/// wrap their body with it themselves. A page with its own background (the
/// Transaction page's immersive header, the reconciliation line art) overrides
/// `onPageBodyWrapper` instead.
class PrjPageBackground extends StatelessWidget {
  const PrjPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final bottomColor = scheme.primary.withAlpha(10);
    final topColor = scheme.primary.withAlpha(10);

    return Stack(
      // Expand so the body keeps the tight constraints it had without a
      // background.
      fit: StackFit.expand,
      children: [
        BgGradientWidget(topColor: topColor, bottomColor: bottomColor),
        child,
      ],
    );
  }
}
