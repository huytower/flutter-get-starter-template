import 'dart:math';

import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../core/constant/currency_catalog.dart';
import 'exchange_rate_types.dart';

/// Service for converting amounts between currencies using exchange rates
/// with precise minor-unit / decimal-scale handling and policy checks.
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
    ConversionUse use = ConversionUse.display,
  }) async {
    if (fromCurrency.toUpperCase() == toCurrency.toUpperCase()) {
      return Success(amount);
    }

    final fromDef = CurrencyCatalog.tryGetDefinition(fromCurrency);
    final toDef = CurrencyCatalog.tryGetDefinition(toCurrency);
    if (fromDef == null || toDef == null) {
      return const Error(
        ValidationFailure('Unsupported currency code for conversion'),
      );
    }

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
    final allowed = switch (use) {
      ConversionUse.display => rateResult.isUsableForDisplay,
      ConversionUse.persist => rateResult.isSafeForPersistedConversion,
    };
    if (!allowed) {
      return const Error(
        CacheFailure('No sufficiently fresh exchange rate is available'),
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

  /// Batch fetch and convert 1 unit of multiple target currencies to/from a base currency in a single repository call.
  Future<Result<Map<String, int>, CcFailure>> convertAll({
    required String baseCurrency,
    required List<String> targetCurrencies,
    bool isBaseVnd = false,
    DateTime? date,
    ConversionUse use = ConversionUse.display,
  }) async {
    final baseDef = CurrencyCatalog.tryGetDefinition(baseCurrency);
    if (baseDef == null) {
      return const Error(ValidationFailure('Unsupported base currency'));
    }

    final uniqueTargets = targetCurrencies
        .where((c) => c.toUpperCase() != baseDef.code.toUpperCase())
        .toList();

    if (uniqueTargets.isEmpty) {
      return const Success({});
    }

    // If base is VND, fetch rates with USD base and convert quote-to-VND in batch
    final effectiveBase = isBaseVnd ? 'USD' : baseDef.code;
    final effectiveQuotes = isBaseVnd
        ? [...uniqueTargets, 'VND'].map((s) => s.toUpperCase()).toSet().toList()
        : uniqueTargets;

    final result = await _repository.getExchangeRates(
      baseCurrency: effectiveBase,
      quoteCurrencies: effectiveQuotes,
      date: date,
    );

    if (result.isError()) {
      final failure = result.tryGetError()!;
      return Error(
        failure is NetworkExchangeRateFailure
            ? ServerFailure(failure.message ?? 'Failed to fetch exchange rates')
            : CacheFailure('Exchange rate error'),
      );
    }

    final rateResult = result.tryGetSuccess()!;
    final allowed = switch (use) {
      ConversionUse.display => rateResult.isUsableForDisplay,
      ConversionUse.persist => rateResult.isSafeForPersistedConversion,
    };
    if (!allowed) {
      return const Error(
        CacheFailure('No sufficiently fresh exchange rate is available'),
      );
    }

    final table = rateResult.table;
    final converted = <String, int>{};

    if (isBaseVnd) {
      final vndRateAgainstBase = table.rates['VND'] ?? 25982.50;
      for (final target in uniqueTargets) {
        final toDef = CurrencyCatalog.tryGetDefinition(target);
        if (toDef == null) continue;

        final targetRateAgainstBase = table.rates[toDef.code] ?? 1.0;
        // Rate from target to VND = vndRateAgainstBase / targetRateAgainstBase
        final rateToVnd = vndRateAgainstBase / targetRateAgainstBase;

        final unitAmount = pow(10, toDef.decimalDigits).round();
        final double fromScale = pow(10, toDef.decimalDigits).toDouble();
        final majorAmount = unitAmount / fromScale;
        final convertedMajor = majorAmount * rateToVnd;
        converted[target.toUpperCase()] = convertedMajor.round();
      }
    } else {
      final unitAmount = pow(10, baseDef.decimalDigits).round();
      final double fromScale = pow(10, baseDef.decimalDigits).toDouble();
      final majorAmount = unitAmount / fromScale;

      for (final target in uniqueTargets) {
        final toDef = CurrencyCatalog.tryGetDefinition(target);
        if (toDef == null) continue;

        final rate = table.rates[toDef.code];
        if (rate != null) {
          final double toScale = pow(10, toDef.decimalDigits).toDouble();
          final convertedMajor = majorAmount * rate;
          converted[target.toUpperCase()] = (convertedMajor * toScale).round();
        }
      }
    }

    return Success(converted);
  }

  /// Batch convert multiple amounts to a single target currency.
  Future<Result<Map<String, int>, CcFailure>> convertBatch({
    required Map<String, int> amountsByCurrency,
    required String targetCurrency,
    DateTime? date,
    ConversionUse use = ConversionUse.display,
  }) async {
    if (amountsByCurrency.isEmpty) {
      return const Success({});
    }

    final targetDef = CurrencyCatalog.tryGetDefinition(targetCurrency);
    if (targetDef == null) {
      return const Error(
        ValidationFailure('Unsupported target currency code for conversion'),
      );
    }

    final uniqueCurrencies = amountsByCurrency.keys
        .where((c) => c.toUpperCase() != targetDef.code.toUpperCase())
        .toList();

    if (uniqueCurrencies.isEmpty) {
      return Success(amountsByCurrency);
    }

    final quoteDefs = <CurrencyDefinition>[];
    for (final c in uniqueCurrencies) {
      final qDef = CurrencyCatalog.tryGetDefinition(c);
      if (qDef == null) {
        return Error(ValidationFailure('Unsupported currency code: $c'));
      }
      quoteDefs.add(qDef);
    }

    final result = await _repository.getExchangeRates(
      baseCurrency: targetDef.code,
      quoteCurrencies: quoteDefs.map((d) => d.code).toList(),
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
    final allowed = switch (use) {
      ConversionUse.display => rateResult.isUsableForDisplay,
      ConversionUse.persist => rateResult.isSafeForPersistedConversion,
    };
    if (!allowed) {
      return const Error(
        CacheFailure('No sufficiently fresh exchange rate is available'),
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

      final currDef = CurrencyCatalog.tryGetDefinition(currency)!;
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

  Future<Object> convertTotal({
    required Map<String, int> amountsByCurrency,
    required String targetCurrency,
    DateTime? date,
    ConversionUse use = ConversionUse.display,
  }) async {
    if (amountsByCurrency.isEmpty) return const Success(0);

    final targetDef = CurrencyCatalog.tryGetDefinition(targetCurrency);
    if (targetDef == null) {
      return const Error(
        ValidationFailure('Unsupported target currency code for conversion'),
      );
    }

    final grouped = <String, int>{};
    for (final entry in amountsByCurrency.entries) {
      final definition = CurrencyCatalog.tryGetDefinition(entry.key);
      if (definition == null) {
        return Error(
          ValidationFailure('Unsupported currency code: ${entry.key}'),
        );
      }
      grouped.update(
        definition.code,
        (value) => value + entry.value,
        ifAbsent: () => entry.value,
      );
    }

    final convertedGroups = await convertBatch(
      amountsByCurrency: grouped,
      targetCurrency: targetDef.code,
      date: date,
      use: use,
    );
    if (convertedGroups.isError()) {
      return Error(convertedGroups.tryGetError()!);
    }

    return Success(
      convertedGroups.tryGetSuccess()!.values.fold<int>(
        0,
        (sum, amount) => sum + amount,
      ),
    );
  }
}
