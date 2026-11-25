import 'package:equatable/equatable.dart';

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

