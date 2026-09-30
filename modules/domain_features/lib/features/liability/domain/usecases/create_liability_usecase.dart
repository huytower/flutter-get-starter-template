import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/liability_entity.dart';
import '../repositories/liability_repository.dart';

/// Input for [CreateLiabilityUseCase].
class CreateLiabilityParams {
  final String? liabilityId;
  final String direction; // borrow or lend
  final int principalAmount;
  final String categoryId;
  final String categoryLabel;
  final int? categoryIconCode;
  final String? categoryIconFamily;
  final String walletId;
  final String repaymentMethod; // installment or lump_sum
  final List<LiabilityInstallmentEntity>? installments;
  final DateTime? finalDueDate;
  final String? note;
  final DateTime date;
  final bool reminderBeforeDueDate;

  const CreateLiabilityParams({
    this.liabilityId,
    required this.direction,
    required this.principalAmount,
    required this.categoryId,
    required this.categoryLabel,
    this.categoryIconCode,
    this.categoryIconFamily,
    required this.walletId,
    required this.repaymentMethod,
    this.installments,
    this.finalDueDate,
    this.note,
    required this.date,
    this.reminderBeforeDueDate = false,
  });
}

/// Creates or updates a liability (loan / lend) record and records its principal transaction leg.
@lazySingleton
class CreateLiabilityUseCase {
  CreateLiabilityUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
    this._getWalletBookBalance,
  );

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  Future<Result<LiabilityEntity, CcFailure>> call(
    CreateLiabilityParams params,
  ) async {
    if (params.principalAmount <= 0) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_amount_required),
      );
    }
    if (params.walletId.isEmpty) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_wallet_required),
      );
    }
    if (params.categoryId.isEmpty) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_category_required,
        ),
      );
    }
    if (params.date.isAfter(DateTime.now())) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_future_date),
      );
    }

    // For borrow, money flows in (unrestricted balance).
    // For lend, money flows out — block overspending.
    if (params.direction == LiabilityDirection.lend) {
      final balanceResult = await _getWalletBookBalance(params.walletId);
      if (balanceResult.isError()) {
        return Error(balanceResult.tryGetError()!);
      }
      final availableBalance = balanceResult.tryGetSuccess()!;
      if (params.principalAmount > availableBalance) {
        return const Error(
          ValidationFailure(
            CcLocaleKeys.transaction_validation_insufficient_balance,
          ),
        );
      }
    }

    var targetId = params.liabilityId ?? '';
    var updatedPrincipal = params.principalAmount;
    var isUpdate = false;

    if (targetId.isNotEmpty) {
      final existingResult = await _LiabilityRepository.getLiability(targetId);
      if (existingResult.isSuccess()) {
        final existing = existingResult.tryGetSuccess();
        if (existing != null) {
          targetId = existing.id;
          updatedPrincipal += existing.principalAmount;
          isUpdate = true;
        }
      }
    }

    if (targetId.isEmpty) {
      targetId = DateTime.now().microsecondsSinceEpoch.toString();
    }

    final liability = LiabilityEntity(
      id: targetId,
      direction: params.direction,
      principalAmount: updatedPrincipal,
      categoryId: params.categoryId,
      categoryLabel: params.categoryLabel,
      categoryIconCode: params.categoryIconCode,
      categoryIconFamily: params.categoryIconFamily,
      walletId: params.walletId,
      repaymentMethod: params.repaymentMethod,
      installments: params.installments,
      finalDueDate: params.finalDueDate,
      note: params.note,
      createdAt: params.date,
      updatedAt: DateTime.now(),
      reminderBeforeDueDate: params.reminderBeforeDueDate,
      currencyCode: CurrencyConstants.currentPrimaryCurrency,
    );

    final createResult = isUpdate
        ? await _LiabilityRepository.updateLiability(liability)
        : await _LiabilityRepository.createLiability(liability);
    if (createResult.isError()) {
      return Error(createResult.tryGetError()!);
    }

    if (params.principalAmount > 0) {
      final txn = TransactionEntity(
        id: '${liability.id}_init',
        type: params.direction == LiabilityDirection.borrow
            ? TransactionType.debtBorrow
            : TransactionType.debtLend,
        amount: params.principalAmount,
        category: params.categoryLabel,
        categoryId: params.categoryId,
        categoryIconCode: params.categoryIconCode,
        categoryIconFamily: params.categoryIconFamily,
        note: params.note,
        date: params.date,
        walletId: params.walletId,
        liabilityId: liability.id,
        currencyCode: CurrencyConstants.currentPrimaryCurrency,
      );

      final txnResult = await _transactionRepository.createTransaction(txn);
      if (txnResult.isError()) {
        return Error(txnResult.tryGetError()!);
      }
    }

    return Success(liability);
  }
}
