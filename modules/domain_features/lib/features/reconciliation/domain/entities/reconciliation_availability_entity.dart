import 'package:equatable/equatable.dart';

/// Whether the user may reconcile now, for the audit cycle that contains today.
///
/// One reconciliation closes the cycle (the 7 days ending on the audit day).
/// The next one opens the day after [cycleEnd]. A reconciliation made before
/// the user last changed their audit day does not close the cycle.
class ReconciliationAvailabilityEntity extends Equatable {
  const ReconciliationAvailabilityEntity({
    required this.cycleStart,
    required this.cycleEnd,
    this.reconciledAt,
  });

  /// First day of the current cycle (UTC midnight of that calendar day).
  final DateTime cycleStart;

  /// The audit day that ends the current cycle (UTC midnight).
  final DateTime cycleEnd;

  /// When the reconciliation that closed this cycle was made; null while the
  /// cycle is still open.
  final DateTime? reconciledAt;

  bool get hasReconciledThisCycle => reconciledAt != null;

  /// First day the next reconciliation is allowed.
  DateTime get nextOpensOn => cycleEnd.add(const Duration(days: 1));

  /// The audit day that ends the next cycle.
  DateTime get nextDueOn => cycleEnd.add(const Duration(days: 7));

  @override
  List<Object?> get props => [cycleStart, cycleEnd, reconciledAt];
}
