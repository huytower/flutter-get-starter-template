import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/wallet_balance_entity.dart';
import '../repositories/wallet_repository.dart';

/// Computes the book balance for every wallet (used by reconciliation's
/// per-wallet actual-vs-book comparison and the "system total").
@lazySingleton
class GetWalletBalancesUseCase {
  GetWalletBalancesUseCase(
    this._walletRepository,
    this._transactionRepository,
    this._conversionService,
  );

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;
  final CurrencyConversionService _conversionService;

  Future<Result<List<WalletBalanceEntity>, CcFailure>> call() async {
    final walletsResult = await _walletRepository.getWallets();
    if (walletsResult.isError()) {
      return Error(walletsResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final transactions = txnResult.tryGetSuccess()!;
    final balances = <WalletBalanceEntity>[];

    for (final wallet in walletsResult.tryGetSuccess()!) {
      final walletTxns = transactions
          .where((t) => t.walletId == wallet.id)
          .toList();

      var bookBal = wallet.balance;
      for (final txn in walletTxns) {
        int amount = txn.amount;
        if (txn.currencyCode.toUpperCase() !=
            wallet.currencyCode.toUpperCase()) {
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
            bookBal += amount;
            break;
          case TransactionType.expense:
          case TransactionType.transferOut:
          case TransactionType.investmentOut:
          case TransactionType.debtLend:
          case TransactionType.debtRepay:
            bookBal -= amount;
            break;
        }
      }

      balances.add(WalletBalanceEntity(wallet: wallet, bookBalance: bookBal));
    }

    return Success(balances);
  }
}
