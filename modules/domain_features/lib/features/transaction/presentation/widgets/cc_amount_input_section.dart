import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import 'cc_quick_amount_chips.dart';

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
          ),
        ),
        const CcSpaceXS(),
        CcInkWell(
          key: fieldKey,
          onTap: onTap,
          borderRadius: context.brMd,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
              vertical: context.respPadding(CcPaddingParams.SPACE_SM),
            ),
            height: context.respDim(50),
            decoration: BoxDecoration(
              color: context.ccColorScheme.surfaceVariant,
              borderRadius: context.brMd,
              border: Border.all(
                color: isKeypadVisible
                    ? accent
                    : context.ccColorScheme.outlineVariant.withAlpha(10),
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
              ),
            ),
          ),
        ),
        const CcSpaceSM(),
        CcQuickAmountChips(
          amounts: quickAmounts,
          onSelected: onQuickAmountSelected,
          activeColor: accent,
        ),
      ],
    );
  }
}
