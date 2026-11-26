import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// The small message bubble (info icon, text, close "X") shown next to the
/// pulsing guideline dot, e.g. "Create your first investment to grow your
/// wealth" under the Investment direction toggle.
///
/// Not to be confused with the *challenge banner* in the page header
/// (`TransactionChallengeBanner`, "Challenge: N remaining steps").
class GuidelineHintBubble extends StatelessWidget {
  const GuidelineHintBubble({
    super.key,
    required this.text,
    required this.color,
    this.onClose,
    this.widthFactorOnTablet = defaultWidthFactorOnTablet,
  });

  /// Every guideline bubble is 70% of its phone-sized width on tablets.
  static const double defaultWidthFactorOnTablet = 0.7;

  final String text;

  /// Colour of the leading info icon (the current guideline step colour).
  final Color color;

  /// Called by the close "X".
  final VoidCallback? onClose;

  /// Scales the bubble's maximum width from a tablet window (medium, 600 dp)
  /// up; phones always use the full width.
  final double widthFactorOnTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxWidth(context, constraints)),
        child: _buildBody(context),
      ),
    );
  }

  /// Half the window fits a phone, but on a small (~7") tablet held sideways
  /// the badge sits in one of two half-width columns: half the window would
  /// run past the column's edge, so the bubble is narrower there and wraps
  /// onto a second line instead. The result is also capped to the space the
  /// bubble is given, so it never runs past its parent.
  double _maxWidth(BuildContext context, BoxConstraints constraints) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    final windowCap = CcTwoColumn.hasSmallTablet(context)
        ? windowWidth * 0.3
        : windowWidth * 0.5;
    final hasTablet = context.windowSizeClass.hasAtLeast(
      CcWindowSizeClass.medium,
    );
    final cap = hasTablet ? windowCap * widthFactorOnTablet : windowCap;
    return constraints.hasBoundedWidth
        ? cap.clamp(0, constraints.maxWidth).toDouble()
        : cap;
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: context.brLg,
        border: Border.all(
          color: context.ccColorScheme.onSurface.withValues(alpha: 0.08),
          width: 0.5,
        ),
        boxShadow: [
          const BoxShadow(
            color: CcBaseColors.neutral40,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoIcon(context),
          const CcSpaceXS(),
          _buildText(context),
          const CcSpaceXS(),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildInfoIcon(BuildContext context) {
    return Container(
      width: context.respDim(15),
      height: context.respDim(15),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(
        Icons.info_sharp,
        size: context.respDim(14),
        color: context.ccColorScheme.onPrimary,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Flexible(
      child: CcText(
        text,
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onSurface,
          fontWeight: CcTypographyParams.medium,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        Icons.close_outlined,
        size: context.respDim(15),
        color: context.ccColorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}
