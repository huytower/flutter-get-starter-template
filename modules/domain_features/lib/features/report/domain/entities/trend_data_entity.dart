import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

import 'trend_point.dart';

export 'trend_point.dart';

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
