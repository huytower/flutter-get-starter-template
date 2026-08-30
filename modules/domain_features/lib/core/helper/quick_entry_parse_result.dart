/// A simple data class to hold the result of parsing a quick entry string.
class QuickEntryParseResult {
  const QuickEntryParseResult({
    this.amount,
    this.categoryId,
    this.date,
    this.note,
  });

  final int? amount;
  final String? categoryId;
  final DateTime? date;
  final String? note;

  bool get isComplete => amount != null || categoryId != null;

  bool get isEmpty => amount == null && categoryId == null;

  QuickEntryParseResult copyWith({
    int? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return QuickEntryParseResult(
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'categoryId': categoryId,
    'date': date?.toIso8601String(),
    'note': note,
    'isComplete': isComplete,
  };

  @override
  String toString() => toJson().toString();
}
