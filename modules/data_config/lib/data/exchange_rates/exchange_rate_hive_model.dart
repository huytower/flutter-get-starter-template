import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
import 'package:hive_ce/hive_ce.dart';

part 'exchange_rate_hive_model.g.dart';

@HiveType(typeId: CcHiveBox.EXCHANGE_RATE_TYPE_ID)
class ExchangeRateHiveModel extends HiveObject {
  @HiveField(0)
  final String baseCurrency;

  @HiveField(1)
  final String effectiveDate;

  @HiveField(2)
  final DateTime fetchedAt;

  @HiveField(3)
  final String provider;

  @HiveField(4)
  final Map<String, double> rates;

  @HiveField(5)
  final List<String> quoteCurrencies;

  ExchangeRateHiveModel({
    required this.baseCurrency,
    required this.effectiveDate,
    required this.fetchedAt,
    required this.provider,
    required this.rates,
    required this.quoteCurrencies,
  });

  factory ExchangeRateHiveModel.fromTable(
    ExchangeRateTable table,
    List<String> quotes,
  ) {
    return ExchangeRateHiveModel(
      baseCurrency: table.baseCurrency,
      effectiveDate: _formatDate(table.effectiveDate),
      fetchedAt: table.fetchedAt,
      provider: table.provider,
      rates: table.rates,
      quoteCurrencies: quotes,
    );
  }

  ExchangeRateTable toTable() {
    return ExchangeRateTable(
      baseCurrency: baseCurrency,
      rates: rates,
      effectiveDate: _parseDate(effectiveDate),
      fetchedAt: fetchedAt,
      provider: provider,
    );
  }

  static String cacheKey(
    String provider,
    String baseCurrency,
    String effectiveDate,
    List<String> quotes,
  ) {
    final sortedQuotes = List<String>.from(quotes)..sort();
    return 'rates_${provider}_${baseCurrency}_${effectiveDate}_${sortedQuotes.join(',')}';
  }

  static String _formatDate(DateTime date) =>
      date.toIso8601String().split('T').first;

  static DateTime _parseDate(String dateStr) => DateTime.parse(dateStr);
}
