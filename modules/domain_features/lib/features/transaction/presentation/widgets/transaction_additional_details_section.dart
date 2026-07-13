import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

class TransactionAdditionalDetailsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Future<void> Function() onCalendarTap;
  final TextEditingController noteController;
  final VoidCallback onNoteTap;
  final Color activeColor;

  const TransactionAdditionalDetailsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onCalendarTap,
    required this.noteController,
    required this.onNoteTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcInkWell(
          onTap: onToggle,
          child: Row(
            children: [
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: context.ccColorScheme.onSurfaceVariant,
                size: context.respDim(24),
              ),
              const CcSpaceSM(),
              Text(
                el.tr(CcLocaleKeys.transaction_more_details),
                style: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const CcSpaceMD(),
          QuickDateRow(
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
            onCalendarTap: onCalendarTap,
            activeColor: activeColor,
          ),
          const CcSpaceMD(),
          CcTextFormField(
            controller: noteController,
            hintText: el.tr(CcLocaleKeys.transaction_note_hint),
            maxLines: 3,
            onTap: onNoteTap,
          ),
        ],
      ],
    );
  }
}
