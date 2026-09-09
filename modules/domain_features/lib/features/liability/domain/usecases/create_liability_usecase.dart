import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import '../entities/liability_entity.dart';
import '../repositories/liability_repository.dart';

/// Input for [CreateLiabilityUseCase].
class CreateLiabilityParams {
  final String? liabilityId;
  final String direction;
  final int principalAmount;
  final String categoryId;
  final String categoryLabel;
  final int? categoryIconCode;
  final String? categoryIconFamily;
  final String walletId;
  final String repaymentMethod;
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

/// Initiates a liability (Đi vay/Cho vay): creates the [LiabilityEntity] plus a single
/// [TransactionEntity] leg tagged with its id.
///
/// Cho vay (lend) mirrors expense/`_contribute`: money leaves the wallet, so
/// it's blocked if it exceeds the wallet's book balance. Đi vay (borrow)
/// mirrors income/`_recordReturn`: money is arriving from outside, no
/// balance check. Rolls back the liability record if the transaction write fails,
/// mirroring the two-leg rollback in `CreateInvestmentTransactionUseCase`.
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
    final scheduleMissing =
        params.direction == LiabilityDirection.borrow &&
        (params.repaymentMethod == LiabilityRepaymentMethod.installment
            ? (params.installments == null || params.installments!.isEmpty)
            : params.finalDueDate == null);
    if (scheduleMissing) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_schedule_required,
        ),
      );
    }

    if (params.direction == LiabilityDirection.lend) {
      final balanceResult = await _getWalletBookBalance(params.walletId);
      if (balanceResult.isError()) {
        return Error(balanceResult.tryGetError()!);
      }
      if (params.principalAmount > balanceResult.tryGetSuccess()!) {
        return const Error(
          ValidationFailure(
            CcLocaleKeys.transaction_validation_insufficient_balance,
          ),
        );
      }
    }

    final liability = LiabilityEntity(
      id:
          params.liabilityId ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      direction: params.direction,
      principalAmount: params.principalAmount,
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
    );

    final createResult = params.liabilityId != null
        ? await _LiabilityRepository.updateLiability(liability)
        : await _LiabilityRepository.createLiability(liability);
    if (createResult.isError()) {
      return Error(createResult.tryGetError()!);
    }

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
    );

    final txnResult = await _transactionRepository.createTransaction(txn);
    if (txnResult.isError()) {
      await _LiabilityRepository.deleteLiability(liability.id);
      return Error(txnResult.tryGetError()!);
    }

    return Success(liability);
  }
}
