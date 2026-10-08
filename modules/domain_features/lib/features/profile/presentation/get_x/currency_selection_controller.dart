import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

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
  bool _initialized = false;

  bool get isInitialized => _initialized;

  void init(String initialCurrencyCode) {
    if (_initialized) return;
    _initialized = true;
    primaryCurrencyCode.value = CurrencyConstants.validateCurrencyCode(
      initialCurrencyCode,
    );
    unawaited(loadConvertedRates());
  }

  void setPrimaryCurrency(String code) {
    final normalized = CurrencyConstants.validateCurrencyCode(code);
    if (primaryCurrencyCode.value.toUpperCase() == normalized) return;
    primaryCurrencyCode.value = normalized;
    unawaited(loadConvertedRates());
  }

  void toggleHiddenTags() {
    showHiddenTags.value = !showHiddenTags.value;
  }

  Future<void> loadConvertedRates() async {
    final requestCurrency = primaryCurrencyCode.value;
    convertedAmounts.clear();
    isLoadingRates.clear();
    final requestId = Object();
    _activeRequest = requestId;
    final baseCurrency = requestCurrency;

    final bool isBaseVnd = baseCurrency.toUpperCase() == 'VND';
    final otherCodes = CurrencyConstants.supportedCurrencyCodes
        .where((c) => c.toUpperCase() != baseCurrency.toUpperCase())
        .toList();

    for (final code in otherCodes) {
      isLoadingRates[code] = true;
    }

    final result = await _conversionService.convertAll(
      baseCurrency: baseCurrency,
      targetCurrencies: otherCodes,
      isBaseVnd: isBaseVnd,
    );

    if (!identical(_activeRequest, requestId)) return;

    for (final code in otherCodes) {
      isLoadingRates[code] = false;
    }

    result.when(
      (map) {
        convertedAmounts.assignAll(map);
      },
      (error) {
        for (final code in otherCodes) {
          convertedAmounts[code] = 0;
        }
        debugPrint(
          '[CurrencySelectionController] Batch rate conversion failed for base $baseCurrency: $error',
        );
      },
    );
  }

  Object? _activeRequest;
}
