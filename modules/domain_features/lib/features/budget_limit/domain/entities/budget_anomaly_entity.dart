import 'package:equatable/equatable.dart';

class BudgetAnomalyEntity extends Equatable {
  final String budgetName;
  final int thisMonthSpend;
  final double avgPrevMonths;

  const BudgetAnomalyEntity({
    required this.budgetName,
    required this.thisMonthSpend,
    required this.avgPrevMonths,
  });

  @override
  List<Object?> get props => [budgetName, thisMonthSpend, avgPrevMonths];
}
