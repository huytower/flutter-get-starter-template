import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Input for [CreateTransactionUseCase].
class CreateTransactionParams {
  /// `'income'` or `'expense'`.
  final String type;
  final int amount;

  /// FK to the selected [CategoryEntity] (expense only).
  final String categoryId;

  /// Denormalized category label stored for display.
  final String categoryLabel;

  final int? categoryIconCode;
  final String? categoryIconFamily;

  final String? budgetId;

  final String walletId;
  final String? note;
  final DateTime date;

  /// Foreground-only GPS fix captured when the entry form opened (Phase 3.5
  /// location-based suggestion). Null when unavailable/denied.
  final double? lat;
  final double? lng;

  const CreateTransactionParams({
    required this.type,
    required this.amount,
    this.categoryId = '',
    this.categoryLabel = '',
    this.categoryIconCode,
    this.categoryIconFamily,
    this.budgetId,
    required this.walletId,
    this.note,
    required this.date,
    this.lat,
    this.lng,
  });
}

/// Records an income/expense transaction — the app's core "nhập Thu/Chi" flow.
///
/// Budget-spend aggregation matches expenses by category + calendar month, so
/// no budget link is stored on the transaction.
@lazySingleton
class CreateTransactionUseCase {
  CreateTransactionUseCase(
    this._transactionRepository,
    this._walletRepository,
    this._getWalletBookBalance,
  );

  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  Future<Result<TransactionEntity, CcFailure>> call(
    CreateTransactionParams params,
  ) async {
    if (params.amount <= 0) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_amount_required),
      );
    }
    if (params.walletId.isEmpty) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_wallet_required),
      );
    }
    if (params.type == 'expense' && params.categoryId.isEmpty) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_category_required,
        ),
      );
    }
    // A transaction can't happen in the future — guard in case a caller passes
    // one regardless of the date-picker's bounds.
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_future_date),
      );
    }

    // Block overspending: an expense can't exceed the wallet's book balance
    // (no negative balances). Income is unrestricted.
    if (params.type == 'expense') {
      final balanceResult = await _getWalletBookBalance(params.walletId);
      if (balanceResult.isError()) {
        return Error(balanceResult.tryGetError()!);
      }
      if (params.amount > balanceResult.tryGetSuccess()!) {
        return const Error(
          ValidationFailure(
            CcLocaleKeys.transaction_validation_insufficient_balance,
          ),
        );
      }
    }

    final transaction = TransactionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: params.type,
      amount: params.amount,
      category: params.categoryLabel,
      categoryId: params.categoryId,
      categoryIconCode: params.categoryIconCode,
      categoryIconFamily: params.categoryIconFamily,
      budgetId: params.budgetId,
      note: params.note,
      date: params.date,
      walletId: params.walletId,
      lat: params.lat,
      lng: params.lng,
    );

    final result = await _transactionRepository.createTransaction(transaction);
    if (result.isError()) {
      return Error(result.tryGetError()!);
    }

    // High Priority Logic: Update updatedAt so this wallet jumps to the front
    // of the horizontal strip on the dashboard.
    final walletResult = await _walletRepository.getWallet(params.walletId);
    if (walletResult.isSuccess()) {
      final wallet = walletResult.tryGetSuccess()!;
      await _walletRepository.updateWallet(
        wallet.copyWith(updatedAt: DateTime.now()),
      );
    }

    return Success(transaction);
  }
}
