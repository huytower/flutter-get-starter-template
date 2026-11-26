import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/transaction_repository.dart';
import '../services/reconciled_period_lock.dart';

/// Deletes (soft) a transaction the user picked, unless it is already part
/// of a reconciliation ([ReconciledPeriodLock]).
///
/// For user deletes only: system flows that must remove their own records
/// (reconciliation undo, rollback of a half-written transfer) call the
/// repository directly.
@injectable
class DeleteTransactionUseCase {
  DeleteTransactionUseCase(this._transactionRepository, this._periodLock);

  final TransactionRepository _transactionRepository;
  final ReconciledPeriodLock _periodLock;

  Future<Result<void, CcFailure>> call(TransactionEntity transaction) async {
    if (await _periodLock.hasReconciled(transaction)) {
      return const Error(
        CcValidationFailure(PrjLocaleKeys.transaction_validation_reconciled),
      );
    }
    return _transactionRepository.deleteTransaction(transaction.id);
  }
}
