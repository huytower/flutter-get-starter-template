import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'smart_entry_sheet_header.dart';

typedef SmartEntryPickerOption = ({String id, String label, IconData icon});

class SmartEntryOptionPickerSheet extends StatelessWidget {
  const SmartEntryOptionPickerSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
  });

  final String title;
  final List<SmartEntryPickerOption> options;
  final String selectedId;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<SmartEntryPickerOption> options,
    required String selectedId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmartEntryOptionPickerSheet(
        title: title,
        options: options,
        selectedId: selectedId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmartEntrySheetHeader(title: title),
          DecoratedBox(
            decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  vertical: context.respPadding(CcPaddingParams.SPACE_SM),
                ),
                itemCount: options.length,
                itemBuilder: (context, index) =>
                    _buildOption(context, options[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, SmartEntryPickerOption option) {
    final scheme = context.ccColorScheme;
    final isSelected = option.id == selectedId;

    return CcBouncing(
      onTap: () => Navigator.of(context).pop(option.id),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        child: Row(
          children: [
            CcIconToken(
              option.icon,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              size: 20,
            ),
            const CcSpaceMD(),
            Expanded(
              child: CcText(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: isSelected ? scheme.primary : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              CcIconToken(Icons.check_rounded, color: scheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
