import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Chi ra (capital into a position) vs Thu vào (return/profit recorded on it).
enum InvestmentDirectionForm { contribute, returnProfit }

/// Input for [CreateInvestmentTransactionUseCase].
class CreateInvestmentTransactionParams {
  final InvestmentDirectionForm direction;

  /// The real (cash/bank/ewallet/emergency fund) wallet involved. Required
  /// for both directions: for [contribute] capital leaves this wallet; for
  /// [returnProfit] the recorded profit is credited to this wallet (real
  /// money should land somewhere spendable, not inside the abstract
  /// investment position).
  final String? liquidWalletId;

  /// An existing investment position (`WalletType.investment`). Required
  /// unless [newItemName] is given (contribute only).
  final String? investmentWalletId;

  /// Name for a brand-new investment position, created on first contribute.
  final String? newItemName;

  final String categoryId;
  final String categoryLabel;
  final int? categoryIconCode;
  final String? categoryIconFamily;

  final int amount;
  final String? note;
  final DateTime date;

  const CreateInvestmentTransactionParams({
    required this.direction,
    this.liquidWalletId,
    this.investmentWalletId,
    this.newItemName,
    required this.categoryId,
    required this.categoryLabel,
    this.categoryIconCode,
    this.categoryIconFamily,
    required this.amount,
    this.note,
    required this.date,
  });
}

/// Records a Chi ra/Thu vào move against an investment position
/// (`WalletType.investment`), creating the wallet on first contribute when
/// [CreateInvestmentTransactionParams.investmentWalletId] is null.
@lazySingleton
class CreateInvestmentTransactionUseCase {
  CreateInvestmentTransactionUseCase(
    this._transactionRepository,
    this._walletRepository,
    this._getWalletBookBalance,
    this._conversionService,
  );

  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;
  final CurrencyConversionService _conversionService;

  Future<Result<WalletEntity, CcFailure>> call(
    CreateInvestmentTransactionParams params,
  ) async {
    if (params.amount <= 0) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_amount_required),
      );
    }
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_future_date),
      );
    }

    final walletResult = await _resolveInvestmentWallet(params);
    if (walletResult.isError()) {
      return Error(walletResult.tryGetError()!);
    }
    final investmentWallet = walletResult.tryGetSuccess()!;

    if (params.investmentWalletId != null) {
      await _walletRepository.updateWallet(
        investmentWallet.copyWith(updatedAt: DateTime.now()),
      );
    }

    if (params.direction == InvestmentDirectionForm.contribute) {
      return _contribute(params, investmentWallet);
    }
    return _recordReturn(params, investmentWallet);
  }

  Future<Result<WalletEntity, CcFailure>> _contribute(
    CreateInvestmentTransactionParams params,
    WalletEntity investmentWallet,
  ) async {
    final liquidWalletId = params.liquidWalletId!;
    final liquidWalletResult = await _walletRepository.getWallet(
      liquidWalletId,
    );
    if (liquidWalletResult.isError()) {
      return Error(liquidWalletResult.tryGetError()!);
    }
    final liquidWallet = liquidWalletResult.tryGetSuccess()!;

    final inputCurrency = CurrencyConstants.currentPrimaryCurrency;
    int finalLiquidAmount = params.amount;
    if (inputCurrency.toUpperCase() !=
        liquidWallet.currencyCode.toUpperCase()) {
      final convResult = await _conversionService.convertAmount(
        amount: params.amount,
        fromCurrency: inputCurrency,
        toCurrency: liquidWallet.currencyCode,
      );
      if (convResult.isSuccess()) {
        finalLiquidAmount = convResult.tryGetSuccess()!;
      }
    }

    final balanceResult = await _getWalletBookBalance(liquidWalletId);
    if (balanceResult.isError()) {
      return Error(balanceResult.tryGetError()!);
    }
    if (finalLiquidAmount > balanceResult.tryGetSuccess()!) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_insufficient_balance,
        ),
      );
    }

    int finalInvestmentAmount = params.amount;
    if (inputCurrency.toUpperCase() !=
        investmentWallet.currencyCode.toUpperCase()) {
      final convResult = await _conversionService.convertAmount(
        amount: params.amount,
        fromCurrency: inputCurrency,
        toCurrency: investmentWallet.currencyCode,
      );
      if (convResult.isSuccess()) {
        finalInvestmentAmount = convResult.tryGetSuccess()!;
      }
    }

    final linkId = DateTime.now().microsecondsSinceEpoch.toString();
    final legOut = TransactionEntity(
      id: '${linkId}_out',
      type: TransactionType.investmentOut,
      amount: finalLiquidAmount,
      category: params.categoryLabel,
      categoryId: params.categoryId,
      categoryIconCode: params.categoryIconCode,
      categoryIconFamily: params.categoryIconFamily,
      note: params.note,
      date: params.date,
      walletId: liquidWalletId,
      transferId: linkId,
      investmentWalletId: investmentWallet.id,
      currencyCode: liquidWallet.currencyCode,
    );
    final legIn = legOut.copyWith(
      id: '${linkId}_in',
      amount: finalInvestmentAmount,
      walletId: investmentWallet.id,
      type: TransactionType.investmentIn,
      currencyCode: investmentWallet.currencyCode,
    );

    final outResult = await _transactionRepository.createTransaction(legOut);
    if (outResult.isError()) {
      return Error(outResult.tryGetError()!);
    }

    final inResult = await _transactionRepository.createTransaction(legIn);
    if (inResult.isError()) {
      await _transactionRepository.deleteTransaction(legOut.id);
      return Error(inResult.tryGetError()!);
    }

    return Success(investmentWallet);
  }

  Future<Result<WalletEntity, CcFailure>> _recordReturn(
    CreateInvestmentTransactionParams params,
    WalletEntity investmentWallet,
  ) async {
    final liquidWalletId = params.liquidWalletId!;
    final liquidWalletResult = await _walletRepository.getWallet(
      liquidWalletId,
    );
    if (liquidWalletResult.isError()) {
      return Error(liquidWalletResult.tryGetError()!);
    }
    final liquidWallet = liquidWalletResult.tryGetSuccess()!;

    final inputCurrency = CurrencyConstants.currentPrimaryCurrency;
    int finalLiquidAmount = params.amount;
    if (inputCurrency.toUpperCase() !=
        liquidWallet.currencyCode.toUpperCase()) {
      final convResult = await _conversionService.convertAmount(
        amount: params.amount,
        fromCurrency: inputCurrency,
        toCurrency: liquidWallet.currencyCode,
      );
      if (convResult.isSuccess()) {
        finalLiquidAmount = convResult.tryGetSuccess()!;
      }
    }

    final txn = TransactionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: TransactionType.investmentReturn,
      amount: finalLiquidAmount,
      category: params.categoryLabel,
      categoryId: params.categoryId,
      categoryIconCode: params.categoryIconCode,
      categoryIconFamily: params.categoryIconFamily,
      note: params.note,
      date: params.date,
      walletId: liquidWalletId,
      investmentWalletId: investmentWallet.id,
      currencyCode: liquidWallet.currencyCode,
    );

    final result = await _transactionRepository.createTransaction(txn);
    if (result.isError()) {
      return Error(result.tryGetError()!);
    }
    return Success(investmentWallet);
  }

  Future<Result<WalletEntity, CcFailure>> _resolveInvestmentWallet(
    CreateInvestmentTransactionParams params,
  ) async {
    if (params.investmentWalletId != null) {
      return _walletRepository.getWallet(params.investmentWalletId!);
    }

    final newWallet = WalletEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: params.newItemName ?? '',
      balance: 0,
      iconCode: params.categoryIconCode ?? 0,
      type: WalletType.investment,
      categoryId: params.categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currencyCode: CurrencyConstants.currentPrimaryCurrency,
    );
    final addResult = await _walletRepository.addWallet(newWallet);
    if (addResult.isError()) {
      return Error(addResult.tryGetError()!);
    }
    return Success(newWallet);
  }
}
