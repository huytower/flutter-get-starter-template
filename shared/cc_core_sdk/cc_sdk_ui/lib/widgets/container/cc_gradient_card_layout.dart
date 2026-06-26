import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_padding_params.dart';
import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';

/// A reusable layout widget that provides a gradient background
/// and a centered card container, similar to the Login page style.
class CcGradientCardLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;

  const CcGradientCardLayout({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final Widget card = Center(
      child: SingleChildScrollView(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.PAGE_LG),
              vertical: context.respPadding(CcPaddingParams.PAGE_LG),
            ),
        child: _buildCard(context),
      ),
    );

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
      child: card,
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth:
            maxWidth ??
            (context.isPortrait ? context.respDim(500) : context.respDim(600)),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.respDim(CcPaddingParams.DESC_LG),
        ),
        boxShadow: [
          BoxShadow(
            color: context.ccColorScheme.shadow.withOpacity(0.1),
            blurRadius: context.respDim(20),
            offset: Offset(0, context.respDim(10)),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_XL)),
      child: child,
    );
  }
}
