import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import 'reconciliation_guide_sheet.dart';

/// One-line preview of what reconciliation is; opens the guide sheet.
class ReconciliationDescriptionBanner extends StatelessWidget {
  const ReconciliationDescriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // The preview is plain text: drop the `**keyword**` markers that the guide
    // sheet turns into emphasis.
    final text = el
        .tr(PrjLocaleKeys.reconciliation_description_line_1)
        .replaceAll('**', '');
    return CcBouncing(
      onTap: () => ReconciliationGuideSheet.show(context),
      borderRadius: context.brSm,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: context.ccColorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: context.brSm,
        ),
        child: Row(
          children: [
            Expanded(
              child: CcText(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                  fontSize: context.respFontSize(9),
                ),
              ),
            ),
            const CcSpaceXS(),
            CcText(
              el.tr(PrjLocaleKeys.wallet_see_all),
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: context.ccColorScheme.primary,
                fontSize: context.respFontSize(9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
