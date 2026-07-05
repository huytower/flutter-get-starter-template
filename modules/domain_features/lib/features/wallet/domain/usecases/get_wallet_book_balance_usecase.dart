import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';
import 'wallet_balance_calculator.dart';

/// Computes the book balance for a single wallet from its opening balance and
/// transactions.
@lazySingleton
class GetWalletBookBalanceUseCase {
  GetWalletBookBalanceUseCase(this._walletRepository, this._transactionRepository);

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<int, CcFailure>> call(String walletId) async {
    final walletResult = await _walletRepository.getWallet(walletId);
    if (walletResult.isError()) {
      return Error(walletResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getTransactionsByWallet(
      walletId,
    );
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final balance = bookBalanceFromTransactions(
      walletResult.tryGetSuccess()!.balance,
      txnResult.tryGetSuccess()!,
    );
    return Success(balance);
  }
}
