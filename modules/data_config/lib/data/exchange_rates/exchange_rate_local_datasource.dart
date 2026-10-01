import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import 'exchange_rate_hive_model.dart';

@lazySingleton
class ExchangeRateLocalDataSource {
  ExchangeRateLocalDataSource();

  Future<Box<ExchangeRateHiveModel>> get _box async {
    if (!Hive.isBoxOpen(CcHiveBox.APP_BOX_NAME)) {
      await Hive.openBox(CcHiveBox.APP_BOX_NAME);
    }
    return Hive.box<ExchangeRateHiveModel>(CcHiveBox.APP_BOX_NAME);
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
}
