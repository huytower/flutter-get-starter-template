import 'package:equatable/equatable.dart';

import 'loan_entity.dart';

/// Còn nợ (outstanding) vs Đã tất toán (settled), derived from
/// [LoanBalanceEntity.outstandingBalance] — never stored directly.
enum LoanStatus { outstanding, settled }

/// Pairs a [LoanEntity] with its computed outstanding balance
/// (principal − Σ repay/collect transactions), mirroring how wallet book
/// balance is always computed from transactions rather than stored.
class LoanBalanceEntity extends Equatable {
  final LoanEntity loan;
  final int outstandingBalance;

  const LoanBalanceEntity({
    required this.loan,
    required this.outstandingBalance,
  });

  LoanStatus get status =>
      outstandingBalance <= 0 ? LoanStatus.settled : LoanStatus.outstanding;

  @override
  List<Object?> get props => [loan.id, outstandingBalance];
}
