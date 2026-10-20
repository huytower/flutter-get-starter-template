import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/transaction_entity.dart';
import 'create_transaction_usecase.dart';

class BatchSaveResult {
  const BatchSaveResult({required this.saved, this.failure, this.failedAt});

  final int saved;
  final CcFailure? failure;
  final int? failedAt;

  bool get isSuccess => failure == null;
}

@lazySingleton
class CreateTransactionBatchUseCase {
  CreateTransactionBatchUseCase(
    this._createTransaction,
    this._walletRepository,
    this._getWalletBookBalance,
  );

  final CreateTransactionUseCase _createTransaction;
  final WalletRepository _walletRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  Future<BatchSaveResult> call(List<CreateTransactionParams> batch) async {
    final overdrawnAt = await _firstOverdrawnIndex(batch);
    if (overdrawnAt != null) {
      return BatchSaveResult(
        saved: 0,
        failure: const ValidationFailure(
          CcLocaleKeys.transaction_validation_insufficient_balance,
        ),
        failedAt: overdrawnAt,
      );
    }

    for (var i = 0; i < batch.length; i++) {
      final result = await _createTransaction.call(batch[i]);
      final failure = result.tryGetError();
      if (failure != null) {
        return BatchSaveResult(saved: i, failure: failure, failedAt: i);
      }
    }
    return BatchSaveResult(saved: batch.length);
  }

  Future<int?> _firstOverdrawnIndex(List<CreateTransactionParams> batch) async {
    final primary = CurrencyConstants.currentPrimaryCurrency.toUpperCase();
    final spent = <String, int>{};
    final balances = <String, int?>{};

    for (var i = 0; i < batch.length; i++) {
      final params = batch[i];
      if (params.type != TransactionType.expense) continue;

      final walletId = params.walletId;
      if (!balances.containsKey(walletId)) {
        balances[walletId] = await _comparableBalance(walletId, primary);
      }
      final balance = balances[walletId];
      if (balance == null) continue;

      final total = (spent[walletId] ?? 0) + params.amount;
      spent[walletId] = total;
      if (total > balance) return i;
    }
    return null;
  }

  Future<int?> _comparableBalance(String walletId, String primary) async {
    final wallet = (await _walletRepository.getWallet(
      walletId,
    )).tryGetSuccess();
    if (wallet == null || wallet.currencyCode.toUpperCase() != primary) {
      return null;
    }
    return (await _getWalletBookBalance.call(walletId)).tryGetSuccess();
  }
}
