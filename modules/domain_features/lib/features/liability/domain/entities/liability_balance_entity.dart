import 'package:equatable/equatable.dart';

import 'liability_entity.dart';

/// Còn nợ (outstanding) vs Đã tất toán (settled), derived from
/// [LiabilityBalanceEntity.outstandingBalance] — never stored directly.
enum LiabilityStatus { outstanding, settled }

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

  LiabilityStatus get status =>
      outstandingBalance <= 0 ? LiabilityStatus.settled : LiabilityStatus.outstanding;

  @override
  List<Object?> get props => [liability.id, outstandingBalance];
}

