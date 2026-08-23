import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'quick_date_row.dart';

class TransactionAdditionalDetailsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Future<void> Function()? onCalendarTap;
  final TextEditingController noteController;
  final bool hasNoteText;
  final VoidCallback? onNoteTap;
  final Color activeColor;
  final bool hideDate;

  const TransactionAdditionalDetailsSection({
    super.key,
    required this.isExpanded,
    this.onToggle,
    required this.selectedDate,
    required this.onDateSelected,
    this.onCalendarTap,
    required this.noteController,
    required this.hasNoteText,
    this.onNoteTap,
    required this.activeColor,
    this.hideDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onToggle != null) _buildMoreDetailsToggle(context),
        if (isExpanded) _buildExpandedContent(context),
      ],
    );
  }

  Widget _buildMoreDetailsToggle(BuildContext context) {
    if (onToggle == null) return const SizedBox.shrink();
    return SizedBox(
      width: context.respDim(120),
      child: CcInkWell(
        onTap: onToggle,
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: context.ccColorScheme.onSurfaceVariant,
              size: context.respDim(24),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(CcLocaleKeys.transaction_more_details),
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      children: [
        if (!hideDate) ...[
          const CcSpaceMD(),
          QuickDateRow(
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
            onCalendarTap: onCalendarTap,
            activeColor: activeColor,
          ),
          const CcSpaceXS(),
        ],
        _buildNoteField(context),
      ],
    );
  }

  Widget _buildNoteField(BuildContext context) {
    return CcTextField(
      controller: noteController,
      hintText: el.tr(CcLocaleKeys.transaction_note_hint),
      maxLines: 2,
      textAlign: TextAlign.start,
      onTap: onNoteTap,
      color: context.ccColorScheme.surfaceVariant.withAlpha(80),
      height: context.respDim(45),
      borderWidth: 0.4,
      margin: EdgeInsets.zero,
      borderRadius: 12.0,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasNoteText)
            IconButton(
              icon: Icon(Icons.copy, size: context.respIconSize(baseSize: 18)),
              color: context.ccColorScheme.onSurfaceVariant,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: noteController.text));
              },
              tooltip: el.tr(CcLocaleKeys.common_copy),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (hasNoteText)
            IconButton(
              icon: Icon(Icons.clear, size: context.respIconSize(baseSize: 18)),
              color: context.ccColorScheme.onSurfaceVariant,
              onPressed: () => noteController.clear(),
              tooltip: el.tr(CcLocaleKeys.common_clear),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
