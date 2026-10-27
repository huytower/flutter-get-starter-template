import 'package:cc_sdk/core/extensions/common/cc_logger_extension.dart';
import 'package:cc_sdk_ui/core/config/tokens/cc_typography_params.dart';
import 'package:cc_sdk_ui/core/extensions/cc_context_extension.dart';
import 'package:cc_sdk_ui/core/extensions/common/cc_responsive_extension.dart';
import 'package:cc_sdk_ui/widgets/button/cc_clear_btn.dart';
import 'package:cc_sdk_ui/widgets/button/cc_icon_button.dart';
import 'package:cc_sdk_ui/widgets/chip/cc_suggestion_chip.dart';
import 'package:cc_sdk_ui/widgets/input/cc_glassy_input_bar.dart';
import 'package:cc_sdk_ui/widgets/input/cc_input_bar_layout.dart';
import 'package:cc_sdk_ui/widgets/space/cc_space.dart';
import 'package:cc_sdk_ui/widgets/text/cc_text.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../../core/constant/currency_constants.dart';
import 'voice_ripple_animation_widget.dart';

/// Phase 3.6 "NLP Simple" quick entry — a free-text field ("50k cafe") with
/// a mic button for voice dictation, offering a one-tap prefill suggestion
/// once both amount and category are confidently resolved.
///
/// Refactored to comply with a glassmorphic design pattern and AI context guardrails:
/// [camera icon button] [input text] [audio icon button]
///
/// Lock overlay is handled by the parent widget (TransactionHeaderBanner) using Stack.
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
    this.isLocked = false,
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
  final bool isLocked;

  bool _isSupportedLanguageAndCurrency(BuildContext context) {
    final languageCode = el.EasyLocalization.of(
      context,
    )?.locale.languageCode.toLowerCase();
    final currencyCode = CurrencyConstants.currentPrimaryCurrency.toUpperCase();
    return (languageCode == 'vi' || languageCode == 'en') &&
        currencyCode == 'VND';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupportedLanguageAndCurrency(context)) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputBar(context),
          const CcSpaceXS(),
          _buildSuggestionChip(context),
          _buildErrorMessage(context),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return CcGlassyInputBar(child: _buildInputContent(context));
  }

  Widget _buildInputContent(BuildContext context) {
    return CcInputBarLayout(
      leading: _buildTrailingIcons(context),
      middle: _buildTextField(context),
      trailing: _buildActionGroup(context),
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
          onTap: () {
            // Tapping accepts it immediately, cancelling any auto-save timer
            onApplySuggestion();
          },
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

  Widget _buildActionGroup(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasText = controller.text.isNotEmpty;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasText)
              CcClearBtn(
                onTap: () {
                  controller.clear();
                  onClear?.call();
                },
                baseIconSize: 20,
                width: context.respDim(30),
                height: context.respDim(30),
              ),
            _buildVoiceIcon(context),
          ],
        );
      },
    );
  }

  Widget _buildVoiceIcon(BuildContext context) {
    final scheme = context.ccColorScheme;
    final buttonSize = context.respDim(30);

    void handleMicTap() {
      '[VoiceWorkflow] 🎤 Mic button tapped | isListening=$isListening | text="${controller.text}"'
          .Log('QuickEntrySection');
      onMicTap();
    }

    if (isListening) {
      return VoiceRippleAnimationWidget(
        activeColor: activeColor,
        onTap: handleMicTap,
        size: buttonSize,
      );
    }

    return CcIconButton.bouncing(
      icon: Icon(
        Icons.mic_none_rounded,
        color: scheme.onSurface.withOpacity(0.45),
        size: context.respDim(20),
      ),
      onTap: handleMicTap,
      width: buttonSize,
      height: buttonSize,
    );
  }

  Widget _buildTrailingIcons(BuildContext context) {
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

    // Temporarily disabled camera icon due to crashes.
    return const SizedBox.shrink();
  }
}
