import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
      return _VoiceRippleAnimationWidget(
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

    return CcIconButton.bouncing(
      icon: Icon(
        Icons.camera_alt,
        color: scheme.onSurface.withOpacity(0.45),
        size: context.respDim(20),
      ),
      onTap: onScanTap,
      width: context.respDim(30),
      height: context.respDim(30),
    );
  }
}

class _VoiceRippleAnimationWidget extends StatefulWidget {
  const _VoiceRippleAnimationWidget({
    required this.activeColor,
    required this.onTap,
    required this.size,
  });

  final Color activeColor;
  final VoidCallback onTap;
  final double size;

  @override
  State<_VoiceRippleAnimationWidget> createState() =>
      __VoiceRippleAnimationWidgetState();
}

class __VoiceRippleAnimationWidgetState
    extends State<_VoiceRippleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress1 = _controller.value;
          final progress2 = (progress1 + 0.5) % 1.0;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer expanding ripple ring 1
              _buildRippleRing(progress1),
              // Inner expanding ripple ring 2
              _buildRippleRing(progress2),
              // Center button with soft red background
              CcBouncing(
                onTap: widget.onTap,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.activeColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic_rounded,
                      color: widget.activeColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRippleRing(double progress) {
    final scale = 1.0 + (progress * 0.7);
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.45;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.activeColor.withOpacity(opacity),
            width: 1.5,
          ),
          color: widget.activeColor.withOpacity(opacity * 0.25),
        ),
      ),
    );
  }
}
