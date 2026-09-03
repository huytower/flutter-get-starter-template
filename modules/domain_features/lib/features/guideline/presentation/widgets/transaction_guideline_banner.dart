import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../guideline_controller.dart';

/// A specialized banner for the Transaction page that displays the current
/// guideline task and cannot be dismissed via tap.
class TransactionGuidelineBanner extends StatelessWidget {
  const TransactionGuidelineBanner({
    super.key,
    this.onTap,
    this.shouldHideDescription = false,
  });

  final VoidCallback? onTap;

  /// Whether to hide the description even if the task is active (e.g. on wrong tab).
  final bool shouldHideDescription;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GuidelineController>()) {
      return const SizedBox.shrink();
    }

    final guideline = Get.find<GuidelineController>();

    return Obx(() {
      // For the Transaction page, we never hide the banner if a task is active.
      if (guideline.currentTaskId == null) {
        return const SizedBox.shrink();
      }

      return CcListBannerSmall(
        title: guideline.bannerTitle,
        description: shouldHideDescription ? null : guideline.bannerDescription,
        accentColor: guideline.currentColor,
        onTap: () {
          // Note: We do NOT set isBannerHidden = true here because the user
          // wants this banner to stay visible always on the Transaction page.

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
