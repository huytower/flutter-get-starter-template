import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/currency_catalog.dart';
import '../../../../core/constant/currency_constants.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../../core/getx/cc_get_controller.dart';

@injectable
class CurrencySelectionController extends CcGetController {
  CurrencySelectionController(this._conversionService);

  final CurrencyConversionService _conversionService;

  final RxString primaryCurrencyCode = 'VND'.obs;
  final RxBool showHiddenTags = false.obs;
  final RxMap<String, int> convertedAmounts = <String, int>{}.obs;
  final RxMap<String, bool> isLoadingRates = <String, bool>{}.obs;

  void init(String initialCurrencyCode) {
    primaryCurrencyCode.value = initialCurrencyCode;
    loadConvertedRates();
  }

  void setPrimaryCurrency(String code) {
    primaryCurrencyCode.value = code;
    loadConvertedRates();
  }

  void toggleHiddenTags() {
    showHiddenTags.value = !showHiddenTags.value;
  }

  Future<void> loadConvertedRates() async {
    final baseCurrency = primaryCurrencyCode.value;
    final baseDef =
        CurrencyCatalog.tryGetDefinition(baseCurrency) ??
        CurrencyCatalog.definitions.first;

    final bool isBaseVnd = baseCurrency.toUpperCase() == 'VND';

    for (final code in CurrencyConstants.supportedCurrencyCodes) {
      if (code.toUpperCase() == baseCurrency.toUpperCase()) continue;

      isLoadingRates[code] = true;
      final codeDef = CurrencyCatalog.tryGetDefinition(code);
      if (codeDef == null) continue;

      // If base is VND, convert 1 unit of row 'code' to VND (e.g. 1 USD -> VND).
      // If base is major currency (USD/EUR...), convert 1 unit of base to row 'code' (e.g. 1 USD -> CNY).
      final fromCur = isBaseVnd ? code : baseCurrency;
      final toCur = isBaseVnd ? baseCurrency : code;
      final fromDef = isBaseVnd ? codeDef : baseDef;

      final unitAmount = pow(10, fromDef.decimalDigits).round();

      final result = await _conversionService.convertAmount(
        amount: unitAmount,
        fromCurrency: fromCur,
        toCurrency: toCur,
      );

      isLoadingRates[code] = false;
      result.when(
        (converted) {
          convertedAmounts[code] = converted;
        },
        (error) {
          convertedAmounts[code] = 0;
          debugPrint(
            '[CurrencySelectionController] Rate conversion failed for $fromCur -> $toCur: $error',
          );
        },
      );
    }
  }
}
