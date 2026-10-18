import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/di/di.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../get_x/smart_suggestion_source.dart';

class TransactionSmartSuggestionChip extends StatelessWidget {
  const TransactionSmartSuggestionChip({
    super.key,
    required this.source,
    required this.accentColor,
  });

  final SmartSuggestionSource source;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final suggestion = source.activeSuggestion;
      if (suggestion == null) return const SizedBox.shrink();

      final match = suggestion.match;
      final targetCurrency = source.suggestionCurrencyCode;

      if (match.currencyCode.toUpperCase() == targetCurrency.toUpperCase() ||
          match.amount == 0) {
        return _buildChip(suggestion, match.amount, targetCurrency);
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
          return _buildChip(suggestion, convertedAmount, targetCurrency);
        },
      );
    });
  }

  Widget _buildChip(SmartSuggestion suggestion, int amount, String currency) {
    final formattedAmount = MoneyFormatter.formatShortWithSymbol(
      amount,
      currencyCode: currency,
    );
    final label = el.tr(
      suggestion.hintKey,
      namedArgs: {'label': '${suggestion.match.category} · $formattedAmount'},
    );

    return CcSuggestionChip(
      label: label,
      accentColor: accentColor,
      icon: suggestion.icon,
      onTap: () async => await source.applyActiveSuggestion(),
      onDismiss: source.dismissActiveSuggestion,
    );
  }
}
