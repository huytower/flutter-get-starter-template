import 'package:equatable/equatable.dart';

/// One period of an installment ([LiabilityRepaymentMethod.installment]) schedule.
class LiabilityInstallmentEntity extends Equatable {
  final DateTime dueDate;
  final int amount;

  const LiabilityInstallmentEntity({
    required this.dueDate,
    required this.amount,
  });

  @override
  List<Object?> get props => [dueDate, amount];
}

