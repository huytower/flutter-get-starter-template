import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Phase 3.6 "NLP Simple" quick entry — a free-text field ("50k cafe") with
/// a mic button for voice dictation, offering a one-tap prefill suggestion
/// once both amount and category are confidently resolved (locally, or via
/// the consent-gated cloud fallback — see `ExpenseFormController`). Purely
/// presentational, mirrors `TransactionAdditionalDetailsSection`'s
/// primitive-params shape rather than taking the whole controller.
///
/// Also carries Phase 3.7's receipt-photo entry point (the leading camera
/// icon) — it feeds the exact same suggestion/error state as the text/voice
/// path, so no separate UI is needed for it here.
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
    required this.onScanTap,
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
  final VoidCallback onScanTap;
  final VoidCallback onApplySuggestion;
  final VoidCallback onDismissSuggestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CcSpaceSM(),
        CcTextField(
          controller: controller,
          height: context.respDim(38),
          borderRadius: 8,
          borderWidth: 0.5,
          hintText: el.tr(CcLocaleKeys.quick_entry_hint),
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmitted,
          prefixIcon: _buildScanIcon(context),
          suffixIcon: _buildTrailingIcon(context),
          // Locked while a parse/cloud-call is in flight — belt-and-braces
          // alongside the controller's own reentrancy guard, so a fast
          // double-submit isn't even possible from the UI, not just a no-op.
          enabled: !isParsing,
          maxLines: 1,
          margin: EdgeInsets.zero,
        ),
        const CcSpaceXS(),
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
          const CcSpaceXS(),
        ],
        if (errorText != null) ...[
          CcText(
            errorText!,
            fontSize: CcTypographyParams.labelSmall,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: context.ccColorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const CcSpaceXS(),
        ],
      ],
    );
  }

  /// Phase 3.7 receipt-photo entry point — opens the take-photo/choose-
  /// gallery action sheet (built by the caller in `expense_form.dart`, which
  /// owns a `BuildContext` for `showModalBottomSheet`).
  Widget _buildScanIcon(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        Icons.camera_alt_outlined,
        color: context.ccColorScheme.onSurfaceVariant,
        size: context.respIconSize(baseSize: 16),
      ),
      onPressed: isParsing ? null : onScanTap,
    );
  }

  Widget _buildTrailingIcon(BuildContext context) {
    if (isParsing) {
      return Padding(
        padding: EdgeInsets.all(context.respPadding(8.0)),
        child: SizedBox(
          width: context.respDim(8),
          height: context.respDim(8),
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
      );
    }
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        color: isListening
            ? activeColor
            : context.ccColorScheme.onSurfaceVariant,
        size: context.respIconSize(baseSize: 16),
      ),
      onPressed: isParsing ? null : onMicTap,
    );
  }
}
