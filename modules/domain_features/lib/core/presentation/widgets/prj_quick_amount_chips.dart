import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/presentation/helper/transaction_form_helpers.dart';
import 'package:flutter/material.dart';

/// A horizontal scrollable strip of chip-like buttons for selecting
/// common monetary amounts.
class PrjQuickAmountChips extends StatelessWidget {
  const PrjQuickAmountChips({
    super.key,
    required this.amounts,
    required this.onSelected,
    required this.activeColor,
    this.padding,
    this.currencyCode,
  });

  final List<int> amounts;
  final void Function(int) onSelected;
  final Color activeColor;
  final EdgeInsetsGeometry? padding;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    if (amounts.isEmpty) return const SizedBox.shrink();

    return CcHorizontalFadeScrollView(
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
                key: ValueKey('chip_$amount'),
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
                    TransactionFormHelpers.formatShortWithSymbol(
                      amount,
                      currencyCode:
                          currencyCode ??
                          CurrencyConstants.currentPrimaryCurrency,
                    ),
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
