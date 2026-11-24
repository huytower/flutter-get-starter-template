import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

/// Phase 3.7 receipt-photo entry point — lets the user choose where the
/// receipt/screenshot image comes from before [ExpenseFormController]
/// hands off to [ReceiptImagePickerHelper].
///
/// Resolves to `true` (camera), `false` (gallery), or `null` (dismissed
/// without a choice).
class ReceiptSourceSheet extends StatelessWidget {
  const ReceiptSourceSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return CcAdaptiveBottomSheet.show<bool>(
      context: context,
      backgroundColor: null,
      builder: (_) => const ReceiptSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CcPickerSheetFrame(
      title: el.tr(PrjLocaleKeys.quick_entry_scan_receipt),
      body: Padding(
        padding: EdgeInsets.only(
          top: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(
              context,
              icon: Icons.camera_alt_outlined,
              label: el.tr(PrjLocaleKeys.quick_entry_take_photo),
              onTap: () => Navigator.of(context).pop(true),
            ),
            _buildRow(
              context,
              icon: Icons.photo_library_outlined,
              label: el.tr(PrjLocaleKeys.quick_entry_choose_gallery),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
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
