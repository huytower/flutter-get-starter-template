import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

/// Notice shown on VIP-only forms (e.g. adding an investment wallet) while
/// the user is not VIP. App-specific, so it lives here rather than in cc_sdk_ui.
class PrjVipLockBanner extends StatelessWidget {
  const PrjVipLockBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.ccColorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: context.ccColorScheme.primary,
            size: context.respIconSize(baseSize: 24),
          ),
          const CcSpaceSM(),
          Expanded(
            child: CcText(
              el.tr(CcLocaleKeys.profile_vip_subtitle),
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: context.ccColorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
