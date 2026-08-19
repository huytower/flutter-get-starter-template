import 'dart:ui';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Phase 3.6 "NLP Simple" quick entry — a free-text field ("50k cafe") with
/// a mic button for voice dictation, offering a one-tap prefill suggestion
/// once both amount and category are confidently resolved.
///
/// Refactored to comply with a glassmorphic design pattern:
/// [camera icon button] [input text] [audio icon button]
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
    this.onClear,
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
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CcSpaceSM(),
        _buildInputBar(context),
        const CcSpaceXS(),
        _buildSuggestionChip(context),
        _buildErrorMessage(context),
      ],
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final scheme = context.ccColorScheme;
    final isDark = context.isDarkMode;

    return ClipRRect(
      borderRadius: context.brLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: context.respDim(46),
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(isDark ? 0.08 : 0.45),
            borderRadius: context.brLg,
            border: Border.all(
              color: (isDark ? Colors.white : scheme.primary).withOpacity(0.12),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildScanIcon(context),
              Expanded(child: _buildTextField(context)),
              _buildTrailingIcon(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final scheme = context.ccColorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return TextField(
          controller: controller,
          enabled: !isParsing,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmitted,
          style: context.ccTextTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: el.tr(CcLocaleKeys.quick_entry_hint),
            hintStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant.withOpacity(0.4),
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
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

  Widget _buildScanIcon(BuildContext context) {
    return CcIconButton.bouncing(
      width: context.respDim(44),
      height: context.respDim(44),
      icon: Icon(
        Icons.camera_alt_rounded,
        color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.7),
        size: context.respIconSize(baseSize: 20),
      ),
      onTap: onScanTap,
      tooltip: el.tr(CcLocaleKeys.quick_entry_scan_receipt),
    );
  }

  Widget _buildTrailingIcon(BuildContext context) {
    if (isParsing) {
      return Container(
        width: context.respDim(44),
        height: context.respDim(44),
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
        child: Center(
          child: SizedBox(
            width: context.respDim(16),
            height: context.respDim(16),
            child: CircularProgressIndicator(
              strokeWidth: 2,
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
            width: context.respDim(32),
            height: context.respDim(44),
            icon: Icon(
              Icons.close_rounded,
              color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.4),
              size: context.respIconSize(baseSize: 18),
            ),
            onTap: () {
              controller.clear();
              onClear?.call();
            },
            tooltip: el.tr(CcLocaleKeys.common_clear),
          ),
        CcIconButton.bouncing(
          width: context.respDim(44),
          height: context.respDim(44),
          icon: Icon(
            isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: isListening
                ? activeColor
                : context.ccColorScheme.onSurfaceVariant.withOpacity(0.7),
            size: context.respIconSize(baseSize: 22),
          ),
          onTap: onMicTap,
        ),
      ],
    );
  }
}
