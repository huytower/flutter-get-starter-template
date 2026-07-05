import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/wallet_balance_entity.dart';
import '../repositories/wallet_repository.dart';
import 'wallet_balance_calculator.dart';

/// Computes the book balance for every wallet (used by reconciliation's
/// per-wallet actual-vs-book comparison and the "system total").
@lazySingleton
class GetWalletBalancesUseCase {
  GetWalletBalancesUseCase(this._walletRepository, this._transactionRepository);

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

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
    final balances = walletsResult.tryGetSuccess()!.map((wallet) {
      final walletTxns = transactions
          .where((t) => t.walletId == wallet.id)
          .toList();
      return WalletBalanceEntity(
        wallet: wallet,
        bookBalance: bookBalanceFromTransactions(wallet.balance, walletTxns),
      );
    }).toList();

    return Success(balances);
  }
}
