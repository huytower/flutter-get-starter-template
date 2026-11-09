import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/money_format_helper.dart';

class SmartEntryAmountField extends StatelessWidget {
  const SmartEntryAmountField({
    super.key,
    required this.amount,
    required this.currencyCode,
    required this.hasError,
  });

  final int amount;
  final String currencyCode;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final textTheme = context.ccTextTheme;

    final formattedText = amount > 0
        ? MoneyFormatter.formatInput(
            amount.toString(),
            currencyCode: currencyCode,
          )
        : '0';
    final symbol = MoneyFormatter.getSymbol(currencyCode);
    final text = symbol.isNotEmpty ? '$formattedText $symbol' : formattedText;

    return CcText(
      text,
      align: Alignment.center,
      textAlign: TextAlign.center,
      textStyle: textTheme.headlineSmall?.copyWith(
        color: hasError ? scheme.error : scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
