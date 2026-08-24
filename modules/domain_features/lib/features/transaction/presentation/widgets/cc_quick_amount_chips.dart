import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';

/// A horizontal scrollable strip of chip-like buttons for selecting
/// common monetary amounts.
class CcQuickAmountChips extends StatelessWidget {
  const CcQuickAmountChips({
    super.key,
    required this.amounts,
    required this.onSelected,
    required this.activeColor,
    this.padding,
  });

  final List<int> amounts;
  final void Function(int) onSelected;
  final Color activeColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (amounts.isEmpty) return const SizedBox.shrink();

    return HorizontalFadeScrollView(
      height: context.respDim(35),
      builder: (scrollController) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        padding: padding,
        child: Row(
          children: amounts.map((amount) {
            return Padding(
              padding: EdgeInsets.only(right: context.respDim(8)),
              child: CcBouncing(
                onTap: () => onSelected(amount),
                borderRadius: context.brLg,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
                    vertical: context.respPadding(CcPaddingParams.SPACE_XS),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: activeColor.withAlpha(20),
                    borderRadius: context.brLg,
                  ),
                  child: CcText(
                    TransactionFormHelpers.formatShort(amount),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: activeColor,
                      fontWeight: CcTypographyParams.semiBold,
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
