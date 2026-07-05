import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../repositories/reconciliation_repository.dart';

/// Reverts the most recent reconciliation (mirrors `UndoKiemToanUseCase`):
/// deletes its adjustment transactions, then the record itself.
@lazySingleton
class UndoReconciliationUseCase {
  UndoReconciliationUseCase(
    this._reconciliationRepository,
    this._transactionRepository,
  );

  final ReconciliationRepository _reconciliationRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<void, CcFailure>> call() async {
    final latestResult = await _reconciliationRepository.getLatest();
    if (latestResult.isError()) {
      return Error(latestResult.tryGetError()!);
    }

    final latest = latestResult.tryGetSuccess();
    if (latest == null) {
      return const Error(
        ValidationFailure('Không tìm thấy đợt đối soát nào để hoàn tác!'),
      );
    }

    for (final txnId in latest.adjustmentTransactionIds) {
      final deleted = await _transactionRepository.deleteTransaction(txnId);
      if (deleted.isError()) {
        return Error(deleted.tryGetError()!);
      }
    }

    return _reconciliationRepository.deleteReconciliation(latest.id);
  }
}
