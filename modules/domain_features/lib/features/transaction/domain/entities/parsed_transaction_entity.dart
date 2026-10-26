import 'package:equatable/equatable.dart';

class ParsedTransactionEntity extends Equatable {
  const ParsedTransactionEntity({
    this.type,
    this.amount,
    this.categoryId,
    this.walletId,
    this.date,
    this.note,
  });

  final String? type;
  final int? amount;
  final String? categoryId;
  final String? walletId;
  final DateTime? date;
  final String? note;

  bool get isComplete => amount != null || categoryId != null;

  bool get isEmpty => amount == null && categoryId == null;

  ParsedTransactionEntity copyWith({
    String? type,
    int? amount,
    String? categoryId,
    String? walletId,
    DateTime? date,
    String? note,
  }) {
    return ParsedTransactionEntity(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'categoryId': categoryId,
    'walletId': walletId,
    'date': date?.toIso8601String(),
    'note': note,
    'isComplete': isComplete,
  };

  @override
  List<Object?> get props => [type, amount, categoryId, walletId, date, note];

  @override
  String toString() => toJson().toString();
}
