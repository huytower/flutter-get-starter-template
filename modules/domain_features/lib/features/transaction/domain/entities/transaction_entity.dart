import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String type;
  final double amount;
  final String category;
  final String? note;
  final DateTime date;
  final String walletId;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.walletId,
  });

  @override
  List<Object?> get props => [id, type, amount, category, note, date, walletId];
}
