import '../../features/transaction/domain/entities/transaction_entity.dart';
import 'currency_conversion_service.dart';

class DisplayCurrencyConverter {
  const DisplayCurrencyConverter(this._service);

  final CurrencyConversionService _service;

  Future<List<TransactionEntity>> convertTransactions(
    List<TransactionEntity> transactions,
    String targetCurrency,
  ) async {
    if (transactions.isEmpty) return transactions;

    final converted = await Future.wait(
      transactions.map(
        (transaction) => _service.convertAmount(
          amount: transaction.amount,
          fromCurrency: transaction.currencyCode,
          toCurrency: targetCurrency,
        ),
      ),
    );

    return [
      for (var index = 0; index < transactions.length; index++)
        converted[index].when(
          (amount) => transactions[index].copyWith(
            amount: amount,
            currencyCode: targetCurrency,
          ),
          (_) => transactions[index],
        ),
    ];
  }
}
