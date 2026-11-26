import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../guideline_controller.dart';
import 'guideline_badge_view.dart';
import 'guideline_hint_bubble.dart';

/// A wrapper around [GuidelineBadgeView] that automatically connects to
/// [GuidelineController] for centralized state (colors, bounce, and visibility).
///
/// This widget handles the "dismiss on tap" behavior and adaptive styling
/// (colors, animations) based on the current guideline step.
class PrjGuidelineBadge extends StatelessWidget {
  const PrjGuidelineBadge({
    super.key,
    this.size = 6,
    this.showing = true,
    this.label,
    this.onTap,
    this.onLabelTap,
    this.growRight = false,
    this.forceHideLabel = false,
    this.labelAbove = true,
    this.icon,
    this.labelWidthFactorOnTablet =
        GuidelineHintBubble.defaultWidthFactorOnTablet,
  });

  final double size;
  final bool showing;
  final String? label;
  final VoidCallback? onTap;
  final VoidCallback? onLabelTap;
  final bool growRight;
  final bool forceHideLabel;
  final bool labelAbove;
  final IconData? icon;

  /// Width scale of the label bubble ([GuidelineHintBubble]) on tablets;
  /// phones are unchanged. Defaults to
  /// [GuidelineHintBubble.defaultWidthFactorOnTablet].
  final double labelWidthFactorOnTablet;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GuidelineController>()) {
      return const SizedBox.shrink();
    }

    final guideline = Get.find<GuidelineController>();

    return Obx(
      () => GuidelineBadgeView(
        size: size,
        color: guideline.currentColor,
        showing: showing,
        bounceTrigger: guideline.bounceTrigger.value,
        label: label,
        onTap: () {
          guideline.hasDescriptionHidden.value = true;
          onTap?.call();
        },
        onLabelTap: () {
          guideline.hasDescriptionHidden.value = true;
          onLabelTap?.call();
        },
        growRight: growRight,
        hasDescriptionHidden: guideline.hasDescriptionHidden.value,
        forceHideLabel: forceHideLabel,
        labelAbove: labelAbove,
        icon: icon,
        labelWidthFactorOnTablet: labelWidthFactorOnTablet,
      ),
    );
  }
}
