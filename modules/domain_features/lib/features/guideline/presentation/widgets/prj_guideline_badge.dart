import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../guideline_controller.dart';

/// A wrapper around [CcGuidelineBadge] that automatically connects to
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

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GuidelineController>()) {
      return const SizedBox.shrink();
    }

    final guideline = Get.find<GuidelineController>();

    return Obx(
      () => CcGuidelineBadge(
        size: size,
        color: guideline.currentColor,
        showing: showing,
        bounceTrigger: guideline.bounceTrigger.value,
        label: label,
        onTap: () {
          guideline.isDescriptionHidden.value = true;
          onTap?.call();
        },
        onLabelTap: () {
          guideline.isDescriptionHidden.value = true;
          onLabelTap?.call();
        },
        growRight: growRight,
        isDescriptionHidden: guideline.isDescriptionHidden.value,
        forceHideLabel: forceHideLabel,
        labelAbove: labelAbove,
        icon: icon,
      ),
    );
  }
}
