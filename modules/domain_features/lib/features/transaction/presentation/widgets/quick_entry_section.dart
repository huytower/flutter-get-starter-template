import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/prj_locale_keys.dart';

import '../../../../core/ai/ai_fallback_preference_datasource.dart';
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
    required this.hasParsing,
    required this.hasListening,
    required this.suggestionLabel,
    required this.hasCategoryMissing,
    required this.errorText,
    required this.activeColor,
    required this.onSubmitted,
    required this.onMicTap,
    required this.onScanTap,
    required this.onApplySuggestion,
    required this.onDismissSuggestion,
    required this.aiPreferences,
    this.onClear,
    this.hasLocked = false,
  });

  final TextEditingController controller;
  final bool hasParsing;
  final bool hasListening;
  final String? suggestionLabel;
  final bool hasCategoryMissing;
  final String? errorText;
  final Color activeColor;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onMicTap;
  final VoidCallback onScanTap;
  final VoidCallback onApplySuggestion;
  final VoidCallback onDismissSuggestion;
  final AiFallbackPreferenceDataSource aiPreferences;
  final VoidCallback? onClear;
  final bool hasLocked;

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
      opacity: hasLocked ? 0.5 : 1.0,
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
          enabled: !hasParsing,
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
            hintText: el.tr(PrjLocaleKeys.quick_entry_hint),
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
            hasCategoryMissing
                ? PrjLocaleKeys.quick_entry_category_missing
                : PrjLocaleKeys.quick_entry_parsed_result,
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
              CcClearButton(
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
      '[VoiceWorkflow] 🎤 Mic button tapped | isListening=$hasListening | text="${controller.text}"'
          .Log('QuickEntrySection');
      onMicTap();
    }

    if (hasListening) {
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
    if (hasParsing) {
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

    final buttonSize = context.respDim(30);

    return FutureBuilder<bool>(
      future: aiPreferences.isGeminiEnabled(),
      builder: (context, snapshot) {
        final hasGeminiEnabled = snapshot.data ?? true;
        if (!hasGeminiEnabled) {
          return const SizedBox.shrink();
        }
        return CcIconButton.bouncing(
          icon: Icon(
            Icons.camera_alt_outlined,
            color: context.ccColorScheme.onSurface.withOpacity(0.45),
            size: context.respDim(20),
          ),
          onTap: onScanTap,
          width: buttonSize,
          height: buttonSize,
        );
      },
    );
  }
}
