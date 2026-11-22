import 'package:multiple_result/multiple_result.dart';

import 'exchange_rate_failure.dart';
import 'exchange_rate_result.dart';

/// Domain contract for fetching exchange rates; implemented in `data_config`.
abstract class ExchangeRateRepository {
  Future<Result<ExchangeRateResult, ExchangeRateFailure>> getExchangeRates({
    required String baseCurrency,
    required List<String> quoteCurrencies,
    DateTime? date,
  });
}
