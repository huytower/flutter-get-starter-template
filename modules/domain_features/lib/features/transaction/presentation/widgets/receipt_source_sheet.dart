import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Phase 3.7 receipt-photo entry point — lets the user choose where the
/// receipt/screenshot image comes from before [ExpenseFormController]
/// hands off to [CcReceiptScanHelper].
///
/// Resolves to `true` (camera), `false` (gallery), or `null` (dismissed
/// without a choice).
class ReceiptSourceSheet extends StatelessWidget {
  const ReceiptSourceSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReceiptSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.primaryContainer],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.respDim(16)),
              topRight: Radius.circular(context.respDim(16)),
            ),
          ),
          child: CcText(
            el.tr(CcLocaleKeys.quick_entry_scan_receipt),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: CcTypographyParams.bold,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(context.respDim(16)),
              bottomRight: Radius.circular(context.respDim(16)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.respPadding(CcPaddingParams.SPACE_SM),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRow(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: el.tr(CcLocaleKeys.quick_entry_take_photo),
                  onTap: () => Navigator.of(context).pop(true),
                ),
                _buildRow(
                  context,
                  icon: Icons.photo_library_outlined,
                  label: el.tr(CcLocaleKeys.quick_entry_choose_gallery),
                  onTap: () => Navigator.of(context).pop(false),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        child: Row(
          children: [
            CcIconToken(
              icon,
              color: scheme.onSurfaceVariant,
              size: context.respIconSize(baseSize: 20),
            ),
            const CcSpaceMD(),
            CcText(
              label,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
