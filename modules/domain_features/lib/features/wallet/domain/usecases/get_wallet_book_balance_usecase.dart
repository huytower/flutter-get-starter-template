import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';

/// Computes the book balance for a single wallet from its opening balance and
/// transactions.
@lazySingleton
class GetWalletBookBalanceUseCase {
  GetWalletBookBalanceUseCase(
    this._walletRepository,
    this._transactionRepository,
    this._conversionService,
  );

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;
  final CurrencyConversionService _conversionService;

  Future<Result<int, CcFailure>> call(String walletId) async {
    final walletResult = await _walletRepository.getWallet(walletId);
    if (walletResult.isError()) {
      return Error(walletResult.tryGetError()!);
    }
    final wallet = walletResult.tryGetSuccess()!;

    final txnResult = await _transactionRepository.getTransactionsByWallet(
      walletId,
    );
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final txns = txnResult.tryGetSuccess()!;
    var balance = wallet.balance;
    for (final txn in txns) {
      int amount = txn.amount;
      if (txn.currencyCode.toUpperCase() != wallet.currencyCode.toUpperCase()) {
        final conv = await _conversionService.convertAmount(
          amount: txn.amount,
          fromCurrency: txn.currencyCode,
          toCurrency: wallet.currencyCode,
        );
        amount = conv.tryGetSuccess() ?? txn.amount;
      }

      switch (txn.type) {
        case TransactionType.income:
        case TransactionType.transferIn:
        case TransactionType.investmentIn:
        case TransactionType.investmentReturn:
        case TransactionType.debtBorrow:
        case TransactionType.debtCollect:
          balance += amount;
          break;
        case TransactionType.expense:
        case TransactionType.transferOut:
        case TransactionType.investmentOut:
        case TransactionType.debtLend:
        case TransactionType.debtRepay:
          balance -= amount;
          break;
      }
    }
    return Success(balance);
  }
}
