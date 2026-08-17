/// Local, offline result of parsing a free-text/voice quick-entry string
/// like "50k cafe" — `null` fields mean that part couldn't be determined
/// locally (see `ParseQuickEntryUseCase` for the cloud-LLM fallback).
///
/// Deliberately kept in its own file, not inside `quick_entry_parser_helper
/// .dart` — that file's name matches injectable's `file_name_pattern`
/// (`_helper$`) in `build.yaml`, which auto-registers every public class
/// found there as a DI factory. This is a plain data class, not a service;
/// it was previously getting swept into the DI graph with a broken
/// generated factory (depending on unregistered `int`/`String` types) that
/// would throw at runtime the moment anything called
/// `getIt<QuickEntryParseResult>()`.
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

  /// True once the two fields required to actually save a transaction —
  /// amount and category — are both resolved. [date]/[note] are optional
  /// enrichment and don't factor in: the local parser never produces them,
  /// so requiring them here would force every local-only quick entry to
  /// escalate to the cloud just to check.
  bool get isComplete => amount != null && categoryId != null;

  /// True when nothing at all was determined — no point surfacing an empty
  /// suggestion or merging it into anything.
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
