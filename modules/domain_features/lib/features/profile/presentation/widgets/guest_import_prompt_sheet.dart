import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../firestore/guest_import_prompt_service.dart';

/// Independent bottom sheet widget for prompting guests to link their account
/// and preserve their local records across devices.
class GuestImportPromptSheet extends StatelessWidget {
  const GuestImportPromptSheet({
    super.key,
    required this.prompt,
    required this.onCancel,
    required this.onImport,
  });

  final GuestImportPrompt prompt;
  final VoidCallback onCancel;
  final VoidCallback onImport;

  static Future<bool?> show(
    BuildContext context, {
    required GuestImportPrompt prompt,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => GuestImportPromptSheet(
        prompt: prompt,
        onCancel: () => Navigator.of(sheetContext).pop(false),
        onImport: () => Navigator.of(sheetContext).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFinal = prompt == GuestImportPrompt.finalWarning;
    final scheme = context.ccColorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.respPadding(CcPaddingParams.PAGE_LG),
          context.respPadding(CcPaddingParams.PAGE_LG),
          context.respPadding(CcPaddingParams.PAGE_LG),
          context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: context.respDim(64),
                height: context.respDim(64),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_sync_outlined,
                  size: context.respIconSize(baseSize: 32),
                  color: scheme.primary,
                ),
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(
                isFinal
                    ? CcLocaleKeys.profile_guest_import_final_title
                    : CcLocaleKeys.profile_guest_import_title,
              ),
              align: Alignment.center,
              textStyle: context.ccTextTheme.titleLarge?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: scheme.onSurface,
              ),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(
                isFinal
                    ? CcLocaleKeys.profile_guest_import_final_body
                    : CcLocaleKeys.profile_guest_import_body,
              ),
              align: Alignment.center,
              textAlign: TextAlign.center,
              maxLines: 5,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const CcSpaceXL(),
            Row(
              children: [
                Expanded(
                  child: CcBouncing(
                    onTap: onCancel,
                    borderRadius: BorderRadius.circular(context.respDim(12)),
                    child: Container(
                      height: context.respDim(48),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(
                          context.respDim(12),
                        ),
                      ),
                      child: CcText(
                        el.tr(CcLocaleKeys.common_later),
                        align: Alignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.ccTextTheme.titleMedium?.copyWith(
                          fontWeight: CcTypographyParams.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const CcSpaceMD(),
                Expanded(
                  child: CcBouncing(
                    onTap: onImport,
                    borderRadius: BorderRadius.circular(context.respDim(12)),
                    child: Container(
                      height: context.respDim(48),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(
                          context.respDim(12),
                        ),
                      ),
                      child: CcText(
                        el.tr(CcLocaleKeys.common_guest_import_action),
                        align: Alignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.ccTextTheme.titleMedium?.copyWith(
                          fontWeight: CcTypographyParams.bold,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
