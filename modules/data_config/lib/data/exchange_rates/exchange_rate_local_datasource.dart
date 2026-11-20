import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import 'exchange_rate_hive_model.dart';

class RateCachePolicy {
  const RateCachePolicy({this.maxAge = const Duration(days: 90)});

  final Duration maxAge;
}

@lazySingleton
class ExchangeRateLocalDataSource {
  ExchangeRateLocalDataSource();

  Future<Box<ExchangeRateHiveModel>> get _box async {
    if (!Hive.isBoxOpen(CcHiveBox.EXCHANGE_RATE_BOX_NAME)) {
      await Hive.openBox<ExchangeRateHiveModel>(
        CcHiveBox.EXCHANGE_RATE_BOX_NAME,
      );
    }
    return Hive.box<ExchangeRateHiveModel>(CcHiveBox.EXCHANGE_RATE_BOX_NAME);
  }

  Future<void> cacheRates(ExchangeRateTable table, List<String> quotes) async {
    final box = await _box;
    final effectiveDateStr = table.effectiveDate
        .toIso8601String()
        .split('T')
        .first;
    final model = ExchangeRateHiveModel.fromTable(table, quotes);
    await box.put(
      ExchangeRateHiveModel.cacheKey(
        table.provider,
        table.baseCurrency,
        effectiveDateStr,
        quotes,
      ),
      model,
    );
  }

  Future<ExchangeRateTable?> getCachedRates({
    required String provider,
    required String baseCurrency,
    required String effectiveDateStr,
    required List<String> quotes,
  }) async {
    final box = await _box;
    final model = box.get(
      ExchangeRateHiveModel.cacheKey(
        provider,
        baseCurrency,
        effectiveDateStr,
        quotes,
      ),
    );
    return model?.toTable();
  }

  Future<int> deleteExpired({
    required DateTime now,
    required Duration retention,
  }) async {
    final box = await _box;
    final expiredKeys = <dynamic>[];
    for (final key in box.keys) {
      final model = box.get(key);
      if (model == null) continue;
      final age = now.difference(model.fetchedAt);
      if (age > retention) {
        expiredKeys.add(key);
      }
    }
    if (expiredKeys.isNotEmpty) {
      await box.deleteAll(expiredKeys);
    }
    return expiredKeys.length;
  }
}
