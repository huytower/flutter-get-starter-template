import 'package:equatable/equatable.dart';

enum FinancialRunwayStatus { excellent, good, safe, caution, insufficient }

class FinancialRunwayEntity extends Equatable {
  final int months;
  final int days;
  final String message;
  final double totalBalance;
  final double averageMonthlyExpense;
  final FinancialRunwayStatus? status;

  const FinancialRunwayEntity({
    required this.months,
    required this.days,
    required this.message,
    required this.totalBalance,
    required this.averageMonthlyExpense,
    this.status,
  });

  @override
  List<Object?> get props => [
    months,
    days,
    message,
    totalBalance,
    averageMonthlyExpense,
    status,
  ];
}
