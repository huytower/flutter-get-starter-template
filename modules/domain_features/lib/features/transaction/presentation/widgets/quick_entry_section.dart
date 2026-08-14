import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'cc_form_label.dart';

/// Phase 3.6 "NLP Simple" quick entry — a free-text field ("50k cafe") with
/// a mic button for voice dictation, offering a one-tap prefill suggestion
/// once both amount and category are confidently resolved (locally, or via
/// the consent-gated cloud fallback — see `ExpenseFormController`). Purely
/// presentational, mirrors `TransactionAdditionalDetailsSection`'s
/// primitive-params shape rather than taking the whole controller.
class QuickEntrySection extends StatelessWidget {
  const QuickEntrySection({
    super.key,
    required this.controller,
    required this.isParsing,
    required this.isListening,
    required this.suggestionLabel,
    required this.errorText,
    required this.activeColor,
    required this.onSubmitted,
    required this.onMicTap,
    required this.onApplySuggestion,
    required this.onDismissSuggestion,
  });

  final TextEditingController controller;
  final bool isParsing;
  final bool isListening;
  final String? suggestionLabel;
  final String? errorText;
  final Color activeColor;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onMicTap;
  final VoidCallback onApplySuggestion;
  final VoidCallback onDismissSuggestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(CcLocaleKeys.quick_entry_label)),
        const CcSpaceXS(),
        CcTextField(
          controller: controller,
          hintText: el.tr(CcLocaleKeys.quick_entry_hint),
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmitted,
          suffixIcon: _buildTrailingIcon(context),
          // Locked while a parse/cloud-call is in flight — belt-and-braces
          // alongside the controller's own reentrancy guard, so a fast
          // double-submit isn't even possible from the UI, not just a no-op.
          enabled: !isParsing,
        ),
        if (suggestionLabel != null) ...[
          CcSuggestionChip(
            label: el.tr(
              CcLocaleKeys.quick_entry_parsed_result,
              namedArgs: {'label': suggestionLabel!},
            ),
            accentColor: activeColor,
            icon: Icons.auto_awesome,
            onTap: onApplySuggestion,
            onDismiss: onDismissSuggestion,
          ),
          const CcSpaceSM(),
        ],
        if (errorText != null) ...[
          CcText(
            errorText!,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.error,
            ),
          ),
          const CcSpaceSM(),
        ],
      ],
    );
  }

  Widget _buildTrailingIcon(BuildContext context) {
    if (isParsing) {
      return Padding(
        padding: EdgeInsets.all(context.respPadding(12.0)),
        child: SizedBox(
          width: context.respDim(18),
          height: context.respDim(18),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
      );
    }
    return IconButton(
      icon: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        color: isListening ? activeColor : context.ccColorScheme.onSurfaceVariant,
        size: context.respIconSize(baseSize: 20),
      ),
      onPressed: isParsing ? null : onMicTap,
    );
  }
}
