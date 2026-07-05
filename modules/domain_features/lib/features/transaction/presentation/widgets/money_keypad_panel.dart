import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'quick_numeric_keypad.dart';

/// The money-entry panel shown only while the amount field is focused: a
/// horizontal strip of Momo-style quick-amount suggestions pinned above the
/// numeric keypad, with a "done" action to dismiss it.
class MoneyKeypadPanel extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  /// Called when a suggestion chip is tapped, with the raw amount (e.g. 100000).
  final void Function(int) onSuggestion;

  /// Dismisses the panel ("Xong").
  final VoidCallback onDone;

  final Color activeColor;

  const MoneyKeypadPanel({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    required this.onSuggestion,
    required this.onDone,
    required this.activeColor,
  });

  static const List<int> _suggestions = [
    10000,
    20000,
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];

  String _chipLabel(int value) {
    if (value >= 1000000) {
      final m = value ~/ 1000000;
      final rem = value % 1000000;
      return '${rem == 0 ? '$m' : '${value / 1000000}'}tr';
    }
    final k = value ~/ 1000;
    final rem = value % 1000;
    return '${rem == 0 ? '$k' : '${value / 1000}'}k';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuggestionBar(context),
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

  Widget _buildSuggestionBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        vertical: context.respPadding(CcPaddingParams.PAGE_XS),
      ),
      child: Row(
        children: [
          Expanded(
            // Fade the left edge so earlier chips read lighter and the strip
            // hints there's more to scroll; the right side stays full opacity.
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFFFFFF), Color(0x26FFFFFF)],
                stops: [0.65, 1.0],
              ).createShader(bounds),
              child: SizedBox(
                height: context.respDim(36),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) => const CcSpaceSM(),
                  itemBuilder: (context, index) {
                    final value = _suggestions[index];
                    return GestureDetector(
                      onTap: () => onSuggestion(value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: activeColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: CcText(
                          _chipLabel(value),
                          textStyle: context.ccTextTheme.labelMedium?.copyWith(
                            color: activeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: context.respFontSize(13),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const CcSpaceSM(),
          GestureDetector(
            onTap: onDone,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: CcText(
                'Xong',
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: context.respFontSize(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
