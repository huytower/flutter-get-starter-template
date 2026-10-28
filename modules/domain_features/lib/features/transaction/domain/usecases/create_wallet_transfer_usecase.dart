import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CreateWalletTransferParams {
  final String sourceWalletId;
  final String destinationWalletId;
  final int amount;
  final String categoryLabel;
  final DateTime date;

  const CreateWalletTransferParams({
    required this.sourceWalletId,
    required this.destinationWalletId,
    required this.amount,
    required this.categoryLabel,
    required this.date,
  });
}

@lazySingleton
class CreateWalletTransferUseCase {
  CreateWalletTransferUseCase(
    this._transactionRepository,
    this._walletRepository,
    this._getWalletBookBalance,
    this._conversionService,
  );

  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;
  final CurrencyConversionService _conversionService;

  Future<Result<void, CcFailure>> call(
    CreateWalletTransferParams params,
  ) async {
    if (params.amount <= 0) {
      return const Error(
        ValidationFailure('transaction.validation.amount_required'),
      );
    }
    if (params.sourceWalletId.isEmpty || params.destinationWalletId.isEmpty) {
      return const Error(
        ValidationFailure('transaction.validation.wallet_required'),
      );
    }
    if (params.sourceWalletId == params.destinationWalletId) {
      return const Error(
        ValidationFailure('transaction.validation.transfer_wallets_different'),
      );
    }
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure('transaction.validation.future_date'),
      );
    }

    final sourceResult = await _walletRepository.getWallet(
      params.sourceWalletId,
    );
    if (sourceResult.isError()) return Error(sourceResult.tryGetError()!);
    final destinationResult = await _walletRepository.getWallet(
      params.destinationWalletId,
    );
    if (destinationResult.isError()) {
      return Error(destinationResult.tryGetError()!);
    }

    final source = sourceResult.tryGetSuccess()!;
    final destination = destinationResult.tryGetSuccess()!;
    if (source.type == WalletType.investment ||
        destination.type == WalletType.investment) {
      return const Error(
        ValidationFailure('transaction.validation.transfer_liquid_wallets'),
      );
    }

    final sourceAmount = await _convertAmount(
      params.amount,
      source.currencyCode,
    );
    final destinationAmount = await _convertAmount(
      params.amount,
      destination.currencyCode,
    );
    final balanceResult = await _getWalletBookBalance(source.id);
    if (balanceResult.isError()) return Error(balanceResult.tryGetError()!);
    final currentBookBal = balanceResult.tryGetSuccess()!;

    if (sourceAmount > currentBookBal) {
      return const Error(
        ValidationFailure('transaction.validation.insufficient_balance'),
      );
    }

    final transferId = DateTime.now().microsecondsSinceEpoch.toString();
    final sourceLeg = TransactionEntity(
      id: '${transferId}_out',
      type: TransactionType.transferOut,
      amount: sourceAmount,
      category: params.categoryLabel,
      date: params.date,
      walletId: source.id,
      transferId: transferId,
      currencyCode: source.currencyCode,
    );
    final destinationLeg = TransactionEntity(
      id: '${transferId}_in',
      type: TransactionType.transferIn,
      amount: destinationAmount,
      category: params.categoryLabel,
      date: params.date,
      walletId: destination.id,
      transferId: transferId,
      currencyCode: destination.currencyCode,
    );

    final sourceSave = await _transactionRepository.createTransaction(
      sourceLeg,
    );
    if (sourceSave.isError()) return Error(sourceSave.tryGetError()!);

    final destinationSave = await _transactionRepository.createTransaction(
      destinationLeg,
    );
    if (destinationSave.isError()) {
      await _transactionRepository.deleteTransaction(sourceLeg.id);
      return Error(destinationSave.tryGetError()!);
    }

    await _walletRepository.updateWallet(
      source.copyWith(updatedAt: DateTime.now()),
    );
    await _walletRepository.updateWallet(
      destination.copyWith(updatedAt: DateTime.now()),
    );
    return const Success(null);
  }

  Future<int> _convertAmount(int amount, String currencyCode) async {
    if (CurrencyConstants.currentPrimaryCurrency.toUpperCase() ==
        currencyCode.toUpperCase()) {
      return amount;
    }
    final result = await _conversionService.convertAmount(
      amount: amount,
      fromCurrency: CurrencyConstants.currentPrimaryCurrency,
      toCurrency: currencyCode,
    );
    return result.tryGetSuccess() ?? amount;
  }
}
