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

  /// Transaction date, if the source (receipt/text) actually stated one —
  /// never produced by the local parser, only by the cloud fallback.
  final DateTime? date;

  /// Short free-text note (merchant/item), same cloud-only caveat as [date].
  final String? note;

  /// True once amount+category — the two fields required to save a
  /// transaction — are resolved. [date]/[note] are optional and excluded,
  /// since the local parser never produces them.
  bool get isComplete => amount != null && categoryId != null;

  bool get isEmpty =>
      amount == null && categoryId == null && date == null && note == null;

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
}
