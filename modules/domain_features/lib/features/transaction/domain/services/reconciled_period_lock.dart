import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:injectable/injectable.dart';

import '../../../reconciliation/domain/repositories/reconciliation_repository.dart';

/// Closes the books up to the latest reconciliation.
///
/// A reconciliation fixes every wallet's balance at the moment it is
/// confirmed. A transaction dated at or before that moment is part of the
/// reconciled figures, so it can no longer be edited or deleted: a mistake is
/// corrected with a new offsetting transaction instead. Undoing the latest
/// reconciliation reopens its period, back to the one before it.
@injectable
class ReconciledPeriodLock {
  ReconciledPeriodLock(this._reconciliations);

  final ReconciliationRepository _reconciliations;

  /// The moment the books are closed up to, or null when nothing has been
  /// reconciled yet (or it could not be read).
  Future<DateTime?> lockedUntil() async {
    final result = await _reconciliations.getLatest();
    return result.tryGetSuccess()?.date;
  }

  /// Whether [transaction] falls in the period closed at [lockedUntil].
  static bool hasLocked(TransactionEntity transaction, DateTime? lockedUntil) =>
      lockedUntil != null && !transaction.date.isAfter(lockedUntil);

  /// Whether [transaction] is reconciled now.
  Future<bool> hasReconciled(TransactionEntity transaction) async =>
      hasLocked(transaction, await lockedUntil());
}
