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
  const QuickEntryParseResult({this.amount, this.categoryId});

  final int? amount;
  final String? categoryId;

  bool get isComplete => amount != null && categoryId != null;
  bool get isEmpty => amount == null && categoryId == null;

  QuickEntryParseResult copyWith({int? amount, String? categoryId}) {
    return QuickEntryParseResult(
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
