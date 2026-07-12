import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/transaction_form_helpers.dart';

class CcAmountInputSection extends StatelessWidget {
  final String label;
  final String amountStr;
  final List<int> quickAmounts;
  final bool isKeypadVisible;
  final Color? activeColor;
  final VoidCallback onTap;
  final Function(int) onQuickAmountSelected;
  final GlobalKey? fieldKey;

  const CcAmountInputSection({
    super.key,
    required this.label,
    required this.amountStr,
    required this.quickAmounts,
    required this.isKeypadVisible,
    required this.onTap,
    required this.onQuickAmountSelected,
    this.activeColor,
    this.fieldKey,
  });

  Color _getAccent(BuildContext context) =>
      activeColor ?? context.ccColorScheme.error;

  @override
  Widget build(BuildContext context) {
    final accent = _getAccent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          label,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: context.respFontSize(12),
          ),
        ),
        const CcSpaceXS(),
        GestureDetector(
          key: fieldKey,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isKeypadVisible ? accent : Colors.grey.withOpacity(0.2),
                width: isKeypadVisible ? 1.5 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: CcText(
              '${TransactionFormHelpers.formatAmount(amountStr)} đ',
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accent,
                fontSize: context.respFontSize(24),
              ),
            ),
          ),
        ),
        const CcSpaceXS(),
        _buildQuickAmounts(context, accent),
      ],
    );
  }

  Widget _buildQuickAmounts(BuildContext context, Color accent) {
    return HorizontalFadeScrollView(
      height: context.respDim(36),
      builder: (scrollController) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: Row(
          children: quickAmounts.map((amount) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onQuickAmountSelected(amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CcText(
                    TransactionFormHelpers.formatShort(amount),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                      fontSize: context.respFontSize(12),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
