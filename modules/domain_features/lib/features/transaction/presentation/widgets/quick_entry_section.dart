import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Phase 3.6 "NLP Simple" quick entry — a free-text field ("50k cafe") with
/// a mic button for voice dictation, offering a one-tap prefill suggestion
/// once both amount and category are confidently resolved.
///
/// Refactored to comply with a glassmorphic design pattern and AI context guardrails:
/// [camera icon button] [input text] [audio icon button]
class QuickEntrySection extends StatelessWidget {
  const QuickEntrySection({
    super.key,
    required this.controller,
    required this.isParsing,
    required this.isListening,
    required this.suggestionLabel,
    required this.isCategoryMissing,
    required this.errorText,
    required this.activeColor,
    required this.onSubmitted,
    required this.onMicTap,
    required this.onScanTap,
    required this.onApplySuggestion,
    required this.onDismissSuggestion,
    this.onClear,
  });

  final TextEditingController controller;
  final bool isParsing;
  final bool isListening;
  final String? suggestionLabel;
  final bool isCategoryMissing;
  final String? errorText;
  final Color activeColor;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onMicTap;
  final VoidCallback onScanTap;
  final VoidCallback onApplySuggestion;
  final VoidCallback onDismissSuggestion;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputBar(context),
        const CcSpaceXS(),
        _buildSuggestionChip(context),
        _buildErrorMessage(context),
      ],
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return CcGlassyInputBar(child: _buildInputContent(context));
  }

  Widget _buildInputContent(BuildContext context) {
    return CcInputBarLayout(
      leading: _buildTrailingIcons(context),
      middle: _buildTextField(context),
      trailing: _buildVoiceIcon(context),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final scheme = context.ccColorScheme;
    final textTheme = context.ccTextTheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return TextField(
          controller: controller,
          enabled: !isParsing,
          maxLines: 1,
          textAlign: TextAlign.start,
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmitted,
          style: textTheme.labelSmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.75),
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: el.tr(CcLocaleKeys.quick_entry_hint),
            hintStyle: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChip(BuildContext context) {
    if (suggestionLabel == null) return const SizedBox.shrink();

    return Column(
      children: [
        CcSuggestionChip(
          label: el.tr(
            isCategoryMissing
                ? CcLocaleKeys.quick_entry_category_missing
                : CcLocaleKeys.quick_entry_parsed_result,
            namedArgs: {'label': suggestionLabel!},
          ),
          accentColor: activeColor,
          icon: Icons.auto_awesome,
          onTap: onApplySuggestion,
          onDismiss: onDismissSuggestion,
        ),
        const CcSpaceXS(),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    if (errorText == null) return const SizedBox.shrink();

    return Column(
      children: [
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
    );
  }

  Widget _buildVoiceIcon(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcIconButton.bouncing(
      icon: Icon(
        isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
        color: isListening ? activeColor : scheme.onSurface.withOpacity(0.45),
        size: context.respDim(20),
      ),
      onTap: onMicTap,
      width: context.respDim(30),
      height: context.respDim(30),
    );
  }

  Widget _buildTrailingIcons(BuildContext context) {
    final scheme = context.ccColorScheme;

    if (isParsing) {
      return SizedBox(
        width: context.respDim(30),
        height: context.respDim(30),
        child: Center(
          child: SizedBox(
            width: context.respDim(16),
            height: context.respDim(16),
            child: CircularProgressIndicator(
              strokeWidth: context.respDim(2),
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
        ),
      );
    }

    final hasText = controller.text.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasText)
          CcIconButton.bouncing(
            icon: Icon(
              Icons.close_rounded,
              color: scheme.onSurface.withOpacity(0.45),
              size: context.respDim(20),
            ),
            onTap: () {
              controller.clear();
              onClear?.call();
            },
            width: context.respDim(30),
            height: context.respDim(30),
          ),
        CcIconButton.bouncing(
          icon: Icon(
            Icons.camera_alt,
            color: scheme.onSurface.withOpacity(0.45),
            size: context.respDim(20),
          ),
          onTap: onScanTap,
          width: context.respDim(30),
          height: context.respDim(30),
        ),
      ],
    );
  }
}
