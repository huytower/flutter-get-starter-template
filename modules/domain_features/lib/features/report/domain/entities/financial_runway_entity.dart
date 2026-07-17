import 'package:equatable/equatable.dart';

enum FinancialRunwayStatus { excellent, good, safe, caution, insufficient }

class FinancialRunwayEntity extends Equatable {
  final int months;
  final int days;
  final String message;
  final double totalBalance;
  final double averageMonthlyExpense;

  /// Sum of the monthly limits of all fixed-price (recurring mandatory)
  /// budgets. Used as the mandatory monthly burn when at least one fixed
  /// budget exists, otherwise the historical [averageMonthlyExpense] is used.
  final double fixedMonthlyCost;

  /// The monthly burn actually used for the runway math — [fixedMonthlyCost]
  /// when non-zero, else [averageMonthlyExpense].
  double get monthlyBurn =>
      fixedMonthlyCost > 0 ? fixedMonthlyCost : averageMonthlyExpense;

  final FinancialRunwayStatus? status;

  const FinancialRunwayEntity({
    required this.months,
    required this.days,
    required this.message,
    required this.totalBalance,
    required this.averageMonthlyExpense,
    this.fixedMonthlyCost = 0,
    this.status,
  });

  @override
  List<Object?> get props => [
    months,
    days,
    message,
    totalBalance,
    averageMonthlyExpense,
    fixedMonthlyCost,
    status,
  ];
}
