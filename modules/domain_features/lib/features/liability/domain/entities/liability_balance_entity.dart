import 'package:equatable/equatable.dart';

import 'liability_entity.dart';

/// Pairs a [LiabilityEntity] with its computed outstanding balance
/// (principal − Σ repay/collect transactions), mirroring how wallet book
/// balance is always computed from transactions rather than stored.
class LiabilityBalanceEntity extends Equatable {
  final LiabilityEntity liability;
  final int outstandingBalance;

  const LiabilityBalanceEntity({
    required this.liability,
    required this.outstandingBalance,
  });

  /// Whether the liability has been fully settled (outstanding balance <= 0)
  bool get isSettled => outstandingBalance <= 0;

  @override
  List<Object?> get props => [liability.id, outstandingBalance];
}

