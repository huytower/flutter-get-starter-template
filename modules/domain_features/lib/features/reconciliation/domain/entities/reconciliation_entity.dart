import 'package:equatable/equatable.dart';

import 'reconciliation_allocation_entity.dart';

/// A reconciliation record ("Đối soát / Kiểm toán") — a periodic audit that
/// compares book balances against counted balances and records the outcome.
///
/// Adapted from the web `kiem_toan_tc_tuan` row. The "close-the-books" snapshot
/// (`func_khop_so_ky` / `chot_*` tables) is not modelled in the MVP; the record
/// plus the adjustment transactions are the source of truth.
class ReconciliationEntity extends Equatable {
  final String id;
  final int year;
  final int week;

  /// Σ book balances across wallets ("tong_tien_he_thong").
  final int systemTotal;

  /// Σ counted balances entered by the user ("tong_tien_thuc_te").
  final int actualTotal;

  /// actualTotal − systemTotal ("chenh_lech").
  final int difference;

  final List<ReconciliationAllocationEntity> allocations;

  /// IDs of the adjustment transactions created to make book = reality.
  /// Deleted when the reconciliation is undone.
  final List<String> adjustmentTransactionIds;

  final DateTime date;

  const ReconciliationEntity({
    required this.id,
    required this.year,
    required this.week,
    required this.systemTotal,
    required this.actualTotal,
    required this.difference,
    required this.allocations,
    required this.adjustmentTransactionIds,
    required this.date,
  });

  /// True when book matched reality (no adjustment needed).
  /// Values are integer VND amounts, so an exact 0 difference means balanced.
  bool get isBalanced => difference == 0;

  @override
  List<Object?> get props => [id, year, week, difference, date];
}
