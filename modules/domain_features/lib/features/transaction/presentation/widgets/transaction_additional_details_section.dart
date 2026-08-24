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
    final scheme = context.ccColorScheme;

    return CcTextField(
      controller: noteController,
      hintText: el.tr(CcLocaleKeys.transaction_note_hint),
      maxLines: 2,
      textAlign: TextAlign.start,
      onTap: onNoteTap,
      color: scheme.surfaceVariant.withAlpha(80),
      borderColor: scheme.outlineVariant.withAlpha(10),
      height: context.respDim(45),
      borderWidth: 0.4,
      margin: EdgeInsets.zero,
      borderRadius: 12.0,
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: context.respPadding(CcPaddingParams.SPACE_SM),
          right: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CcText(
              el.tr(CcLocaleKeys.transaction_note),
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant.withAlpha(70),
              ),
            ),
          ],
        ),
      ),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasNoteText)
            CcIconButton.bouncing(
              width: context.respDim(20),
              height: context.respDim(20),
              icon: Icon(
                Icons.copy_rounded,
                color: scheme.onSurfaceVariant.withAlpha(80),
                size: context.respIconSize(baseSize: 14),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: noteController.text));
              },
              tooltip: el.tr(CcLocaleKeys.common_copy),
            ),
          if (hasNoteText)
            CcIconButton.bouncing(
              width: context.respDim(20),
              height: context.respDim(20),
              icon: Icon(
                Icons.close_rounded,
                color: scheme.onSurfaceVariant.withAlpha(80),
                size: context.respIconSize(baseSize: 14),
              ),
              onTap: () => noteController.clear(),
              tooltip: el.tr(CcLocaleKeys.common_clear),
            ),
          const CcSpaceXS(),
        ],
      ),
    );
  }
}
