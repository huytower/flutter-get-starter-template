import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';

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
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: CcTypographyParams.bold,
            fontSize: context.respFontSize(CcTypographyParams.labelMedium),
          ),
        ),
        const CcSpaceXS(),
        GestureDetector(
          key: fieldKey,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
              vertical: context.respPadding(CcPaddingParams.SPACE_SM),
            ),
            height: context.respDim(50),
            decoration: BoxDecoration(
              color: context.ccColorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(context.respDim(12)),
              border: Border.all(
                color: isKeypadVisible
                    ? accent
                    : context.ccColorScheme.outlineVariant,
                width: isKeypadVisible ? 1 : 0.4,
              ),
            ),
            alignment: Alignment.center,
            child: CcText(
              '${TransactionFormHelpers.formatAmount(amountStr)} đ',
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: accent,
                fontSize: context.respFontSize(
                  CcTypographyParams.headlineMedium,
                ),
              ),
            ),
          ),
        ),
        const CcSpaceSM(),
        _buildQuickAmounts(context, accent),
      ],
    );
  }

  Widget _buildQuickAmounts(BuildContext context, Color accent) {
    return HorizontalFadeScrollView(
      height: context.respDim(35),
      builder: (scrollController) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: Row(
          children: quickAmounts.map((amount) {
            return Padding(
              padding: EdgeInsets.only(right: context.respDim(8)),
              child: GestureDetector(
                onTap: () => onQuickAmountSelected(amount),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
                    vertical: context.respPadding(CcPaddingParams.SPACE_XS),
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(context.respDim(20)),
                  ),
                  child: CcText(
                    TransactionFormHelpers.formatShort(amount),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: CcTypographyParams.semiBold,
                      fontSize: context.respFontSize(
                        CcTypographyParams.labelMedium,
                      ),
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
