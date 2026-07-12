import 'package:equatable/equatable.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';

class TrendPoint extends Equatable {
  final String label;
  final double income;
  final double expense;
  final DateTime date;

  const TrendPoint({
    required this.label,
    required this.income,
    required this.expense,
    required this.date,
  });

  @override
  List<Object?> get props => [label, income, expense, date];
}

class TrendDataEntity extends Equatable {
  final List<TrendPoint> points;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionEntity> transactions;

  const TrendDataEntity({
    required this.points,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactions,
  });

  @override
  List<Object?> get props => [points, totalIncome, totalExpense, transactions];
}
