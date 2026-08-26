/// Local, offline result of parsing a free-text/voice quick-entry string
/// like "50k cafe" — `null` fields mean that part couldn't be determined
/// locally (see `ParseQuickEntryUseCase` for the cloud-LLM fallback).
///
/// Kept in its own file rather than inside `quick_entry_parser_helper.dart`
/// — that filename matches injectable's `_helper$` auto-DI pattern, which
/// was registering this plain data class as a broken DI factory.
class QuickEntryParseResult {
  const QuickEntryParseResult({
    this.amount,
    this.categoryId,
    this.date,
    this.note,
  });

  final int? amount;
  final String? categoryId;

  /// Transaction date. Defaults to the moment of parsing in the local parser,
  /// but can be overridden by the cloud fallback if a specific date (e.g.
  /// "yesterday") is detected.
  final DateTime? date;

  /// Short free-text note (merchant/item), same cloud-only caveat as [date].
  final String? note;

  /// True once amount or category — the two fields required to save a
  /// transaction — are resolved. [date]/[note] are optional.
  bool get isComplete => amount != null || categoryId != null;

  /// True if no useful data (amount, category, or note) was resolved. Date is
  /// excluded here because the local parser always provides "now".
  bool get isEmpty => amount == null && categoryId == null && note == null;

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
