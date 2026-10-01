import 'dart:math';

import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../core/constant/currency_catalog.dart';
import 'exchange_rate_types.dart';

/// Service for converting amounts between currencies using exchange rates
/// with precise minor-unit / decimal-scale handling.
@lazySingleton
class CurrencyConversionService {
  CurrencyConversionService(this._repository);

  final ExchangeRateRepository _repository;

  /// Convert an amount from one currency to another.
  Future<Result<int, CcFailure>> convertAmount({
    required int amount,
    required String fromCurrency,
    required String toCurrency,
    DateTime? date,
  }) async {
    if (fromCurrency.toUpperCase() == toCurrency.toUpperCase()) {
      return Success(amount);
    }

    final fromDef = CurrencyCatalog.getDefinition(fromCurrency);
    final toDef = CurrencyCatalog.getDefinition(toCurrency);

    final result = await _repository.getExchangeRates(
      baseCurrency: fromDef.code,
      quoteCurrencies: [toDef.code],
      date: date,
    );

    if (result.isError()) {
      final failure = result.tryGetError()!;
      return Error(
        failure is NetworkExchangeRateFailure
            ? ServerFailure(failure.message ?? 'Failed to fetch exchange rates')
            : CacheFailure(
                failure is CacheExchangeRateFailure
                    ? failure.message ?? 'Failed to load cached exchange rates'
                    : 'Exchange rate error',
              ),
      );
    }

    final rateResult = result.tryGetSuccess()!;
    if (!rateResult.isUsable) {
      return const Error(
        CacheFailure('Exchange rate cache stale or unavailable'),
      );
    }

    final rate = rateResult.table.rates[toDef.code];
    if (rate == null) {
      return Error(
        ValidationFailure('Exchange rate not available for ${toDef.code}'),
      );
    }

    final double fromScale = pow(10, fromDef.decimalDigits).toDouble();
    final double toScale = pow(10, toDef.decimalDigits).toDouble();

    final majorAmount = amount / fromScale;
    final convertedMajor = majorAmount * rate;
    final convertedMinor = (convertedMajor * toScale).round();

    return Success(convertedMinor);
  }

  /// Batch convert multiple amounts to a single target currency.
  Future<Result<Map<String, int>, CcFailure>> convertBatch({
    required Map<String, int> amountsByCurrency,
    required String targetCurrency,
    DateTime? date,
  }) async {
    if (amountsByCurrency.isEmpty) {
      return const Success({});
    }

    final targetDef = CurrencyCatalog.getDefinition(targetCurrency);
    final uniqueCurrencies = amountsByCurrency.keys
        .where((c) => c.toUpperCase() != targetDef.code.toUpperCase())
        .toList();

    if (uniqueCurrencies.isEmpty) {
      return Success(amountsByCurrency);
    }

    final result = await _repository.getExchangeRates(
      baseCurrency: targetDef.code,
      quoteCurrencies: uniqueCurrencies,
      date: date,
    );

    if (result.isError()) {
      final failure = result.tryGetError()!;
      return Error(
        failure is NetworkExchangeRateFailure
            ? ServerFailure(failure.message ?? 'Failed to fetch exchange rates')
            : CacheFailure(
                failure is CacheExchangeRateFailure
                    ? failure.message ?? 'Failed to load cached exchange rates'
                    : 'Exchange rate error',
              ),
      );
    }

    final rateResult = result.tryGetSuccess()!;
    if (!rateResult.isUsable) {
      return const Error(
        CacheFailure('Exchange rate cache stale or unavailable'),
      );
    }

    final table = rateResult.table;
    final converted = <String, int>{};
    final double targetScale = pow(10, targetDef.decimalDigits).toDouble();

    for (final entry in amountsByCurrency.entries) {
      final currency = entry.key;
      final amount = entry.value;

      if (currency.toUpperCase() == targetDef.code.toUpperCase()) {
        converted[currency] = amount;
        continue;
      }

      final currDef = CurrencyCatalog.getDefinition(currency);
      final rate = table.rates[currDef.code];
      if (rate == null) {
        return Error(
          ValidationFailure('Exchange rate not available for $currency'),
        );
      }

      final double currScale = pow(10, currDef.decimalDigits).toDouble();
      final majorAmount = amount / currScale;
      // Note: Frankfurter rates are base-to-quote, so converting from quote to base requires inverse
      final invertedRate = 1.0 / rate;
      final convertedMajor = majorAmount * invertedRate;
      converted[currency] = (convertedMajor * targetScale).round();
    }

    return Success(converted);
  }
}
