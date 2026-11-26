import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'guideline_hint_bubble.dart';

/// Pulsing dot with an optional label bubble pointing at the next step of the
/// onboarding guideline. Pure view: `PrjGuidelineBadge` feeds it the
/// guideline state.
class GuidelineBadgeView extends StatefulWidget {
  const GuidelineBadgeView({
    super.key,
    this.size = 12,
    this.color,
    this.showing = true,
    this.bounceTrigger,
    this.label,
    this.onTap,
    this.onLabelTap,
    this.growRight = false,
    this.hasDescriptionHidden = false,
    this.forceHideLabel = false,
    this.labelAbove = true,
    this.icon,
    this.labelWidthFactorOnTablet =
        GuidelineHintBubble.defaultWidthFactorOnTablet,
  });

  final double size;
  final Color? color;
  final bool showing;
  final String? label;
  final VoidCallback? onTap;
  final VoidCallback? onLabelTap;
  final IconData? icon;

  /// Width scale of the label's [GuidelineHintBubble] on tablets (phones
  /// unchanged). Defaults to [GuidelineHintBubble.defaultWidthFactorOnTablet].
  final double labelWidthFactorOnTablet;

  /// Whether the label bubble should align its left edge with the dot and grow
  /// to the right. Useful for badges on the left side of the screen.
  final bool growRight;

  /// Whether the descriptive text labels on guideline badges are hidden.
  final bool hasDescriptionHidden;

  /// Overrides everything to never show the label text bubble.
  final bool forceHideLabel;

  /// Whether to position the label above (true) or below (false) the dot.
  final bool labelAbove;

  /// Optional trigger to perform a bounce animation. Incremented by parent to trigger.
  final int? bounceTrigger;

  @override
  State<GuidelineBadgeView> createState() => _GuidelineBadgeViewState();
}

class _GuidelineBadgeViewState extends State<GuidelineBadgeView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // Pulse animation (infinite)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    // Bounce animation (one-shot)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.6), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.6, end: 0.8), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 20),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
        ]).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(GuidelineBadgeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bounceTrigger != null &&
        widget.bounceTrigger != oldWidget.bounceTrigger) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showing) return const SizedBox.shrink();

    final label = _buildLabel(context);
    final dot = _buildDot(context);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.growRight
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        if (widget.labelAbove && label != null) ...[label, const CcSpaceXS()],
        dot,
        if (!widget.labelAbove && label != null) ...[const CcSpaceXS(), label],
      ],
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: body,
      );
    }
    return body;
  }

  Widget _buildDot(BuildContext context) {
    final badgeColor = widget.color ?? context.ccColorScheme.primary;
    final dotSize = widget.size * 2.5;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: SizedBox(
          width: dotSize,
          height: dotSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildPulseRings(context, badgeColor),
              _buildCoreDot(context, badgeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseRings(BuildContext context, Color badgeColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * _pulseAnimation.value,
          height: widget.size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: badgeColor.withAlpha(
              (255 * (1.0 - _pulseController.value)).toInt(),
            ),
            border: Border.all(
              color: badgeColor.withAlpha(
                (127 * (1.0 - _pulseController.value)).toInt(),
              ),
              width: 1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoreDot(BuildContext context, Color badgeColor) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withAlpha(100),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: widget.icon != null
          ? Icon(
              widget.icon,
              size: widget.size * 0.6,
              color: context.ccColorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget? _buildLabel(BuildContext context) {
    if (widget.label == null ||
        widget.hasDescriptionHidden ||
        widget.forceHideLabel) {
      return null;
    }

    return GuidelineHintBubble(
      text: widget.label!,
      color: widget.color ?? context.ccColorScheme.primary,
      onClose: widget.onLabelTap,
      widthFactorOnTablet: widget.labelWidthFactorOnTablet,
    );
  }
}
