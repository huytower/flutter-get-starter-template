import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../guideline_controller.dart';

/// A wrapper around [CcListBannerSmall] that automatically connects to
/// [GuidelineController] to show/hide the current guideline step banner.
///
/// This handles the "dismiss on tap" behavior and ensures the banner only
/// shows when a task is active and the banner hasn't been hidden by the user.
class PrjGuidelineBanner extends StatelessWidget {
  const PrjGuidelineBanner({
    super.key,
    this.onTap,
    this.shouldHideDescription = false,
    this.canDismiss = true,
  });

  final VoidCallback? onTap;

  /// Whether to hide the description even if the task is active (e.g. on wrong tab).
  final bool shouldHideDescription;

  /// Whether tapping the banner should dismiss it centrally.
  final bool canDismiss;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GuidelineController>()) {
      return const SizedBox.shrink();
    }

    final guideline = Get.find<GuidelineController>();

    return Obx(() {
      if ((canDismiss && guideline.isBannerHidden.value) ||
          guideline.currentTaskId == null) {
        return const SizedBox.shrink();
      }

      return CcListBannerSmall(
        title: guideline.bannerTitle,
        description: shouldHideDescription ? null : guideline.bannerDescription,
        accentColor: guideline.currentColor,
        onTap: () {
          if (canDismiss) {
            // Dismiss banner on tap
            guideline.isBannerHidden.value = true;
            // Also hide all descriptions/tooltips when the main banner is dismissed
            guideline.isDescriptionHidden.value = true;
          }

          // Trigger bounce animation on the tab bar badge
          guideline.triggerBounce();
          onTap?.call();
        },
        icon: CcClipboardChecklistIcon(
          size: context.respDim(40) * 0.8,
          bodyColor: context.ccColorScheme.onPrimary.withValues(alpha: 0.85),
          clipColor: context.ccColorScheme.onPrimary,
          markColor: guideline.currentColor,
        ),
      );
    });
  }
}
