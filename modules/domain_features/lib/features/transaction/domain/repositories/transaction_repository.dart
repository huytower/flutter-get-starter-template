import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Result<List<TransactionEntity>, CcFailure>> getListTransactions();

  Future<Result<List<TransactionEntity>, CcFailure>> getTransactions(
    PaginationRequest request, {
    String? type,
  });

  Future<Result<void, CcFailure>> createTransaction(
    TransactionEntity transaction,
  );

  /// Overwrites a previously recorded transaction (same [TransactionEntity.id]).
  Future<Result<void, CcFailure>> updateTransaction(
    TransactionEntity transaction,
  );

  Future<Result<void, CcFailure>> deleteTransaction(String id);

  /// Soft-deletes every transaction (income and expense) of a wallet.
  Future<Result<void, CcFailure>> softDeleteByWallet(String walletId);

  /// Soft-deletes the transactions with the given [ids].
  Future<Result<void, CcFailure>> softDeleteByIds(List<String> ids);

  /// Transactions belonging to a wallet.
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByWallet(
    String walletId,
  );

  /// Transactions linked to a liability (initiation + repay/collect legs).
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByLiability(
    String liabilityId,
  );

  /// Transactions counting against a budget.
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByBudget(
    String budgetId,
  );

  /// Transactions within an inclusive [start]..[end] date range.
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  );
}
