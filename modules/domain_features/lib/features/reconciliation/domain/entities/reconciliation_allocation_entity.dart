import 'package:equatable/equatable.dart';

/// Per-wallet snapshot captured during a reconciliation ("chi_tiet_phan_bo"):
/// what the book said vs. what the user counted.
class ReconciliationAllocationEntity extends Equatable {
  final String walletId;
  final String walletName;
  final int bookBalance;
  final int actualBalance;

  const ReconciliationAllocationEntity({
    required this.walletId,
    required this.walletName,
    required this.bookBalance,
    required this.actualBalance,
  });

  /// actual − book; non-zero means a discrepancy was adjusted.
  int get difference => actualBalance - bookBalance;

  @override
  List<Object?> get props => [walletId, bookBalance, actualBalance];
}
