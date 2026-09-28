import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'quick_date_row.dart';

class TransactionAdditionalDetailsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Future<void> Function()? onCalendarTap;
  final TextEditingController noteController;
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: context.ccColorScheme.onSurfaceVariant,
          size: context.respDim(24),
        ),
        const CcSpaceXS(),
        CcBouncing(
          onTap: onToggle,
          child: CcText(
            el.tr(CcLocaleKeys.transaction_more_details),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      children: [
        if (!hideDate) ...[
          QuickDateRow(
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
            onCalendarTap: onCalendarTap,
            activeColor: activeColor,
          ),
          const CcSpaceSM(),
        ],
        _buildNoteField(context),
      ],
    );
  }

  Widget _buildNoteField(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcNoteInputField(
      controller: noteController,
      hintText: el.tr(CcLocaleKeys.transaction_note_hint),
      maxLines: 3,
      onTap: onNoteTap,
      color: scheme.surfaceVariant.withAlpha(80),
      borderColor: scheme.outlineVariant.withAlpha(10),
      height: context.respDim(45),
      margin: EdgeInsets.zero,
    );
  }
}
