import 'package:equatable/equatable.dart';

/// How many times a budget's spending has exceeded its monthly limit so far
/// this month, derived fresh from transaction history (no persisted counter).
class BudgetOverLimitEntity extends Equatable {
  final String budgetName;
  final int count;

  const BudgetOverLimitEntity({required this.budgetName, required this.count});

  @override
  List<Object?> get props => [budgetName, count];
}
