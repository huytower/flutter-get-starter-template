import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;

import '../../../../core/di/di.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_form_controller.dart';

mixin SuggestionPrefillMixin on TransactionFormController {
  void applySuggestedCategory(String categoryId);

  Future<void> prefillFromTransaction(TransactionEntity match) async {
    final targetCurrency = currencyCode.value;
    var amount = match.amount;

    if (match.currencyCode.toUpperCase() != targetCurrency.toUpperCase()) {
      final result = await getIt<CurrencyConversionService>().convertAmount(
        amount: match.amount,
        fromCurrency: match.currencyCode,
        toCurrency: targetCurrency,
      );
      amount = result.tryGetSuccess() ?? match.amount;
    }

    'prefillFromTransaction: rawAmount=${match.amount}, sourceCurrency=${match.currencyCode}, targetCurrency=$targetCurrency, amount=$amount'
        .Log('SuggestionPrefillMixin');

    amountStr.value = amount.toString();
    if (wallets.any((w) => w.id == match.walletId)) {
      selectedWalletId.value = match.walletId;
    }
    applySuggestedCategory(match.categoryId);
  }
}
