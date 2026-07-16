import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/horizontal_fade_scroll_view.dart';
import 'quick_numeric_keypad.dart';

class MoneyKeypadPanel extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;

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
    this.suggestions = const [],
    this.onSuggestion,
    required this.onDone,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Hide soft keyboard when this custom keypad panel is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.focusedChild?.unfocus();
      }
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: context.ccColorScheme.outlineVariant.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.respPadding(CcPaddingParams.SPACE_XS),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: suggestions.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(
                            left: context.respPadding(CcPaddingParams.SPACE_SM),
                          ),
                          child: _buildSuggestionChips(context),
                        ),
                ),
                GestureDetector(
                  onTap: onDone,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.respPadding(CcPaddingParams.SPACE_XL),
                    ),
                    child: CcText(
                      el.tr(CcLocaleKeys.common_done),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: activeColor,
                        fontWeight: CcTypographyParams.bold,
                        fontSize: context.respFontSize(13),
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

  Widget _buildSuggestionChips(BuildContext context) {
    final formatter = el.NumberFormat('#,###', context.locale.toString());
    return HorizontalFadeScrollView(
      height: context.respDim(25),
      builder: (scrollController) => ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const CcSpaceSM(),
        itemBuilder: (context, index) {
          final amount = suggestions[index];
          return GestureDetector(
            onTap: () => onSuggestion?.call(amount),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.respDim(CcPaddingParams.SPACE_XS),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(context.respDim(16)),
              ),
              child: CcText(
                formatter.format(amount),
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: activeColor,
                  fontWeight: CcTypographyParams.bold,
                  fontSize: context.respFontSize(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
