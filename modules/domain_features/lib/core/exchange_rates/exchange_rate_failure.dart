/// Why an exchange-rate lookup failed. Sealed, so its subclasses live in this file.
sealed class ExchangeRateFailure {
  const ExchangeRateFailure();
}

class NetworkExchangeRateFailure extends ExchangeRateFailure {
  const NetworkExchangeRateFailure([this.message]);

  final String? message;
}

class CacheExchangeRateFailure extends ExchangeRateFailure {
  const CacheExchangeRateFailure([this.message]);

  final String? message;
}

class ValidationExchangeRateFailure extends ExchangeRateFailure {
  const ValidationExchangeRateFailure([this.message]);

  final String? message;
}

class UnsupportedCurrencyFailure extends ExchangeRateFailure {
  const UnsupportedCurrencyFailure(this.code);

  final String code;
}
