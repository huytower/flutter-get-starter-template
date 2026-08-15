import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'quick_date_row.dart';

class TransactionAdditionalDetailsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Future<void> Function() onCalendarTap;
  final TextEditingController noteController;
  final bool hasNoteText;
  final VoidCallback? onNoteTap;
  final Color activeColor;

  /// Phase 3.3 "AI Autofill" — when non-null, shows a one-tap suggestion row
  /// below the note field (e.g. "Cà phê · 30.000đ") from the closest-matching
  /// past expense note. Null hides the row entirely.
  final String? merchantSuggestionLabel;
  final VoidCallback? onApplyMerchantSuggestion;
  final VoidCallback? onDismissMerchantSuggestion;

  const TransactionAdditionalDetailsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onCalendarTap,
    required this.noteController,
    required this.hasNoteText,
    this.onNoteTap,
    required this.activeColor,
    this.merchantSuggestionLabel,
    this.onApplyMerchantSuggestion,
    this.onDismissMerchantSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMoreDetailsToggle(context),
        if (isExpanded) _buildExpandedContent(context),
      ],
    );
  }

  Widget _buildMoreDetailsToggle(BuildContext context) {
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
        const CcSpaceMD(),
        QuickDateRow(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
          onCalendarTap: onCalendarTap,
          activeColor: activeColor,
        ),
        const CcSpaceMD(),
        _buildNoteField(context),
        if (merchantSuggestionLabel != null) ...[
          const CcSpaceXS(),
          _buildMerchantSuggestion(context),
        ],
      ],
    );
  }

  Widget _buildMerchantSuggestion(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcInkWell(
      onTap: onApplyMerchantSuggestion,
      borderRadius: context.brMd,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(10),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          color: activeColor.withAlpha(15),
          borderRadius: context.brMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: context.respIconSize(baseSize: 16),
              color: activeColor,
            ),
            const CcSpaceXS(),
            Expanded(
              child: CcText(
                el.tr(
                  CcLocaleKeys.transaction_merchant_match_hint,
                  namedArgs: {'label': merchantSuggestionLabel ?? ''},
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CcInkWell(
              onTap: onDismissMerchantSuggestion,
              borderRadius: context.brSm,
              child: Icon(
                Icons.close,
                size: context.respIconSize(baseSize: 16),
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField(BuildContext context) {
    return CcTextField(
      controller: noteController,
      hintText: el.tr(CcLocaleKeys.transaction_note_hint),
      maxLines: 1,
      onTap: onNoteTap,
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
