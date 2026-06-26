import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';

/// A simple layout widget that provides a branded gradient background.
class CcGradientLayout extends StatelessWidget {
  final Widget child;

  const CcGradientLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.ccColorScheme.surface,
            context.ccColorScheme.primaryContainer,
            context.ccColorScheme.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}
