import 'package:equatable/equatable.dart';

import 'liability_entity.dart';

/// Pairs a [LiabilityEntity] with its computed outstanding balance
/// (principal − Σ repay/collect transactions) and total repaid/received amount.
class LiabilityBalanceEntity extends Equatable {
  final LiabilityEntity liability;
  final int outstandingBalance;
  final int repaidAmount;

  const LiabilityBalanceEntity({
    required this.liability,
    required this.outstandingBalance,
    this.repaidAmount = 0,
  });

  /// Computed repaid / received amount: uses [repaidAmount] if > 0,
  /// otherwise derives it as [liability.principalAmount - outstandingBalance].
  int get effectiveRepaidAmount {
    if (repaidAmount > 0) return repaidAmount;
    final derived = liability.principalAmount - outstandingBalance;
    return derived < 0 ? 0 : derived;
  }

  /// Whether the liability has been fully settled (outstanding balance <= 0)
  bool get isSettled => outstandingBalance <= 0;

  @override
  List<Object?> get props => [liability.id, outstandingBalance, repaidAmount];
}
