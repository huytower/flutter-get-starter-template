import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:equatable/equatable.dart';

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
  bool get hasSettled => outstandingBalance <= 0;

  /// What is still owed, for display: 0 once settled. Older data can hold a
  /// negative balance (more repaid / collected than owed), which must not
  /// read as money still due.
  int get remainingToShow => hasSettled ? 0 : outstandingBalance;

  @override
  List<Object?> get props => [liability.id, outstandingBalance, repaidAmount];
}
