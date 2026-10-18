import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/di/di.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../get_x/expense_form_controller.dart';

class TransactionSmartSuggestionChip extends StatelessWidget {
  const TransactionSmartSuggestionChip({
    super.key,
    required this.expenseFormController,
    required this.accentColor,
  });

  final ExpenseFormController expenseFormController;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final merchantMatch =
          expenseFormController.merchantMatchSuggestion.value;
      final billMatch = expenseFormController.billMatchSuggestion.value;
      final locationMatch =
          expenseFormController.locationMatchSuggestion.value;

      final match = merchantMatch ?? billMatch ?? locationMatch;
      if (match == null) return const SizedBox.shrink();

      final IconData icon = merchantMatch != null
          ? Icons.auto_awesome
          : billMatch != null
          ? Icons.event_repeat
          : Icons.place;

      final String hintKey = merchantMatch != null
          ? CcLocaleKeys.transaction_merchant_match_hint
          : billMatch != null
          ? CcLocaleKeys.transaction_bill_match_hint
          : CcLocaleKeys.transaction_location_match_hint;

      final targetCurrency = expenseFormController.currencyCode.value;

      if (match.currencyCode.toUpperCase() == targetCurrency.toUpperCase() ||
          match.amount == 0) {
        final formattedAmount = MoneyFormatter.formatShortWithSymbol(
          match.amount,
          currencyCode: targetCurrency,
        );
        final label = el.tr(
          hintKey,
          namedArgs: {'label': '${match.category} · $formattedAmount'},
        );
        return CcSuggestionChip(
          label: label,
          accentColor: accentColor,
          icon: icon,
          onTap: () => _applySuggestion(expenseFormController),
          onDismiss: () => _dismissSuggestion(expenseFormController),
        );
      }

      return FutureBuilder<Result<int, CcFailure>>(
        future: getIt<CurrencyConversionService>().convertAmount(
          amount: match.amount,
          fromCurrency: match.currencyCode,
          toCurrency: targetCurrency,
        ),
        builder: (context, snapshot) {
          final convertedAmount =
              snapshot.data?.tryGetSuccess() ?? match.amount;
          final formattedAmount = MoneyFormatter.formatShortWithSymbol(
            convertedAmount,
            currencyCode: targetCurrency,
          );
          final label = el.tr(
            hintKey,
            namedArgs: {'label': '${match.category} · $formattedAmount'},
          );

          return CcSuggestionChip(
            label: label,
            accentColor: accentColor,
            icon: icon,
            onTap: () => _applySuggestion(expenseFormController),
            onDismiss: () => _dismissSuggestion(expenseFormController),
          );
        },
      );
    });
  }

  void _applySuggestion(ExpenseFormController controller) {
    final merchantMatch = controller.merchantMatchSuggestion.value;
    if (merchantMatch != null) {
      controller.applyMerchantMatch(merchantMatch);
      return;
    }
    final billMatch = controller.billMatchSuggestion.value;
    if (billMatch != null) {
      controller.applyBillMatch(billMatch);
      return;
    }
    final locationMatch = controller.locationMatchSuggestion.value;
    if (locationMatch != null) controller.applyLocationMatch(locationMatch);
  }

  void _dismissSuggestion(ExpenseFormController controller) {
    if (controller.merchantMatchSuggestion.value != null) {
      controller.dismissMerchantMatch();
    } else if (controller.billMatchSuggestion.value != null) {
      controller.dismissBillMatch();
    } else {
      controller.dismissLocationMatch();
    }
  }
}
