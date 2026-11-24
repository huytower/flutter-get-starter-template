import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/presentation/widgets/prj_quick_amount_chips.dart';
import 'package:domain_features/core/presentation/widgets/quick_numeric_keypad.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

class MoneyKeypadPanel extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback? onCopy;

  /// Quick-amount suggestions (Momo style) shown as a chip strip above the
  /// keypad; tapping one fires [onSuggestion].
  final List<int> suggestions;
  final void Function(int)? onSuggestion;

  final VoidCallback onDone;
  final Color activeColor;

  const MoneyKeypadPanel({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    this.onCopy,
    this.suggestions = const [],
    this.onSuggestion,
    required this.onDone,
    required this.activeColor,
  });

  /// Width cap on small tablet and up (same as a bottom sheet's).
  static const double _tabletMaxWidth = 480;

  @override
  Widget build(BuildContext context) {
    // Hide soft keyboard when this custom keypad panel is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.focusedChild?.unfocus();
      }
    });

    final scheme = context.ccColorScheme;
    final isTablet = context.windowSizeClass.isAtLeast(
      CcWindowSizeClass.medium,
    );

    if (!isTablet) {
      // Phone: full-width, edge-to-edge panel docked to the bottom.
      return DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: scheme.outlineVariant.withOpacity(0.1)),
          ),
        ),
        child: _buildContent(context),
      );
    }

    // Small tablet and up: styled like a bottom sheet (rounded top corners,
    // shadow, capped width, centred) but with no header, footer or actions, so
    // the keys stay a normal size instead of stretching across the window.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _tabletMaxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // 80% opaque so the page content stays faintly visible behind it.
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.respDim(16).clamp(0, 24).toDouble()),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(0.12),
                blurRadius: context.respDim(12),
                offset: Offset(0, -context.respDim(2)),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.respDim(16).clamp(0, 24).toDouble()),
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  /// Quick amounts, clear / copy / done and the keys; the same on phone and
  /// tablet, which differ only in the container around it.
  Widget _buildContent(BuildContext context) {
    return CcContentPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CcSymmetricPadding(
            vertical: CcPaddingParams.SPACE_XS,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PrjQuickAmountChips(
                    amounts: suggestions,
                    onSelected: (val) => onSuggestion?.call(val),
                    activeColor: activeColor,
                    padding: EdgeInsets.only(
                      left: context.respPadding(CcPaddingParams.SPACE_SM),
                    ),
                  ),
                ),
                CcIconButton.bouncing(
                  icon: Icon(
                    Icons.close_rounded,
                    color: activeColor,
                    size: context.respIconSize(baseSize: 20),
                  ),
                  onTap: onClear,
                  tooltip: el.tr(PrjLocaleKeys.common_clear),
                ),
                if (onCopy != null)
                  CcIconButton.bouncing(
                    icon: Icon(
                      Icons.copy_rounded,
                      color: activeColor,
                      size: context.respIconSize(baseSize: 20),
                    ),
                    onTap: onCopy!,
                    tooltip: el.tr(PrjLocaleKeys.common_copy),
                  ),
                CcBouncing(
                  onTap: onDone,
                  child: CcSymmetricPadding(
                    horizontal: CcPaddingParams.SPACE_XL,
                    child: CcText(
                      el.tr(PrjLocaleKeys.common_done),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: activeColor,
                        fontWeight: CcTypographyParams.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          QuickNumericKeypad(
            onKeyPress: onKeyPress,
            onDelete: onDelete,
            onClear: onClear,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}
