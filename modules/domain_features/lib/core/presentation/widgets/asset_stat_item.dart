import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../constant/currency_constants.dart';
import '../helper/transaction_form_helpers.dart';

class AssetStatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Widget icon;
  final String? currencyCode;

  const AssetStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return CcStatItem(
      label: label,
      formattedValue: TransactionFormHelpers.formatShortWithSymbol(
        value,
        currencyCode:
            currencyCode ?? CurrencyConstants.currentPrimaryCurrency,
      ),
      color: color,
      icon: icon,
    );
  }
}
