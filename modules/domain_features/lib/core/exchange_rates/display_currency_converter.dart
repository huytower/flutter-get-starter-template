import '../../features/transaction/domain/entities/transaction_entity.dart';
import 'currency_conversion_service.dart';
import 'exchange_rate_types.dart';

class DisplayCurrencyConverter {
  const DisplayCurrencyConverter(this._service);

  final CurrencyConversionService _service;

  Future<List<TransactionEntity>> convertTransactions(
    List<TransactionEntity> transactions,
    String targetCurrency,
  ) async {
    if (transactions.isEmpty) return transactions;

    final converted = await _service.convertAmounts(
      amounts: [
        for (final transaction in transactions)
          CurrencyAmount(
            amount: transaction.amount,
            currencyCode: transaction.currencyCode,
          ),
      ],
      targetCurrency: targetCurrency,
    );
    if (converted.isError()) return transactions;
    final convertedAmounts = converted.tryGetSuccess()!;

    return [
      for (var index = 0; index < transactions.length; index++)
        transactions[index].copyWith(
          amount: convertedAmounts[index],
          currencyCode: targetCurrency,
        ),
    ];
  }
}
