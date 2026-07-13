import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theme/export_theme.dart';
import 'quick_date_row.dart';

class TransactionAdditionalDetailsSection extends StatefulWidget {
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
  State<TransactionAdditionalDetailsSection> createState() =>
      _TransactionAdditionalDetailsSectionState();
}

class _TransactionAdditionalDetailsSectionState
    extends State<TransactionAdditionalDetailsSection> {
  bool _hasNoteText = false;

  @override
  void initState() {
    super.initState();
    _hasNoteText = widget.noteController.text.isNotEmpty;
    widget.noteController.addListener(_onNoteChanged);
  }

  @override
  void didUpdateWidget(covariant TransactionAdditionalDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteController != widget.noteController) {
      oldWidget.noteController.removeListener(_onNoteChanged);
      _hasNoteText = widget.noteController.text.isNotEmpty;
      widget.noteController.addListener(_onNoteChanged);
    }
  }

  @override
  void dispose() {
    widget.noteController.removeListener(_onNoteChanged);
    super.dispose();
  }

  void _onNoteChanged() {
    if (mounted) {
      setState(() {
        _hasNoteText = widget.noteController.text.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcInkWell(
          onTap: widget.onToggle,
          child: Row(
            children: [
              Icon(
                widget.isExpanded ? Icons.expand_less : Icons.expand_more,
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
        if (widget.isExpanded) ...[
          const CcSpaceMD(),
          QuickDateRow(
            selectedDate: widget.selectedDate,
            onDateSelected: widget.onDateSelected,
            onCalendarTap: widget.onCalendarTap,
            activeColor: widget.activeColor,
          ),
          const CcSpaceMD(),
          CcTextField(
            controller: widget.noteController,
            hintText: el.tr(CcLocaleKeys.transaction_note_hint),
            maxLines: 1,
            onTap: widget.onNoteTap,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasNoteText)
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: context.respIconSize(baseSize: 18),
                    ),
                    color: context.ccColorScheme.onSurfaceVariant,
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: widget.noteController.text),
                      );
                    },
                    tooltip: el.tr(CcLocaleKeys.common_copy),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (_hasNoteText)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: context.respIconSize(baseSize: 18),
                    ),
                    color: context.ccColorScheme.onSurfaceVariant,
                    onPressed: () => widget.noteController.clear(),
                    tooltip: el.tr(CcLocaleKeys.common_clear),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
