import 'package:string_similarity/string_similarity.dart';

import '../../features/category/domain/entities/category_entity.dart';
import 'merchant_match_helper.dart';
import 'quick_entry_parse_result.dart';

export 'quick_entry_parse_result.dart';

const int _thousand = 1000;
const int _million = 1000000;

final Map<String, int> _amountUnitMultipliers = {
  'k': _thousand,
  'nghin': _thousand,
  'tr': _million,
  'trieu': _million,
};

// Grouped-thousands form (e.g. "1.500.000") is tried before the plain
// digit-run fallback — without it, "1.500.000" mis-parsed as 1500, since
// allMatches only consumes one `[.,]` group per match.
final RegExp _amountPattern = RegExp(
  r'(\d{1,3}(?:[.,]\d{3})+|\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu|d|vnd)?',
);

/// Parses a Vietnamese money shorthand out of [text] — `50k`, `50.000`,
/// `1tr`, `1,5tr`, `500 nghin`, plain `500000`, optional `đ`/`vnd` suffix.
/// Null if nothing plausible (a bare number under 1000 with no unit is
/// treated as ambiguous, not guessed at).
///
/// Prefers the *last* number carrying an explicit unit/currency suffix over
/// the first digit run — "2 ly cafe 50k" states an unmarked quantity before
/// the real price, so taking the first number would misread the quantity as
/// the amount.
///
/// Uses [stripVietnameseDiacritics], not the full [normalizeMerchantText] —
/// the latter strips punctuation too, deleting the `.`/`,` separators this
/// function's regex depends on.
int? parseVietnameseAmount(String text) {
  final normalized = stripVietnameseDiacritics(text);
  final matches = _amountPattern.allMatches(normalized).toList();
  if (matches.isEmpty) return null;

  RegExpMatch? lastWithUnit;
  for (final m in matches) {
    if (m.group(2) != null) lastWithUnit = m;
  }
  final match = lastWithUnit ?? matches.first;

  final numeric = match.group(1)!;
  final unit = match.group(2);

  if (unit == null) {
    final digitsOnly = numeric.replaceAll(RegExp('[.,]'), '');
    final value = int.tryParse(digitsOnly);
    if (value == null || value < _thousand) return null;
    return value;
  }

  if (unit == 'd' || unit == 'vnd') {
    final digitsOnly = numeric.replaceAll(RegExp('[.,]'), '');
    return int.tryParse(digitsOnly);
  }

  final multiplier = _amountUnitMultipliers[unit];
  if (multiplier == null) return null;
  final asDouble = double.tryParse(numeric.replaceAll(',', '.'));
  if (asDouble == null) return null;
  return (asDouble * multiplier).round();
}

/// Informal/English shorthand mapped to a seed category id, checked before
/// the fuzzy label match — these words don't reliably fuzzy-match their
/// formal Vietnamese label (e.g. "cafe" vs. "cà phê").
const Map<String, String> _categoryKeywordAliases = {
  'cafe': 'c2',
  'coffee': 'c2',
  'ca phe': 'c2',
  'xang': 'c6',
  'do xang': 'c6',
  'taxi': 'c5',
  'grab': 'c5',
  'com trua': 'c4',
  'an trua': 'c4',
  'an toi': 'c4',
  'dien': 'c9',
  'tien dien': 'c9',
  'wifi': 'c10',
  'dien thoai': 'c11',
  'nap the': 'c11',
  'thue nha': 'c12',
  'thuoc': 'c18',
  'bac si': 'c17',
  'kham benh': 'c17',
  'gym': 'c20',
  'xem phim': 'c24',
  'du lich': 'c25',
  'quan ao': 'c30',
  'cat toc': 'c39',
};

/// Shortest normalized text worth attempting a category match on.
const int _minCategoryQueryLength = 2;

/// [_categoryKeywordAliases] sorted longest-key-first, so a shorter alias
/// that's also a substring of a longer one (e.g. "dien" vs. "dien thoai")
/// never wins just because it's declared earlier.
final List<MapEntry<String, String>> _sortedCategoryKeywordAliases =
    _categoryKeywordAliases.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

/// Best-effort local category match: alias table, then label-containment,
/// then fuzzy match. [categoryLabels] is passed in (rather than reading
/// `el.tr` directly) so this stays pure and testable without a locale.
/// Returns null when nothing is confident enough.
String? matchCategoryIdFromText({
  required String text,
  required List<CategoryEntity> categories,
  required String Function(CategoryEntity) categoryLabels,
  double fuzzyThreshold = 0.4,
}) {
  final normalizedText = normalizeMerchantText(text);
  if (normalizedText.length < _minCategoryQueryLength) return null;
  if (categories.isEmpty) return null;

  for (final entry in _sortedCategoryKeywordAliases) {
    if (normalizedText.contains(entry.key) &&
        categories.any((c) => c.id == entry.value)) {
      return entry.value;
    }
  }

  final normalizedLabels = {
    for (final c in categories) c.id: normalizeMerchantText(categoryLabels(c)),
  };

  String? bestContainmentMatch;
  int bestContainmentLength = 0;
  for (final c in categories) {
    final label = normalizedLabels[c.id]!;
    if (label.isEmpty) continue;
    if (normalizedText.contains(label) && label.length > bestContainmentLength) {
      bestContainmentMatch = c.id;
      bestContainmentLength = label.length;
    }
  }
  if (bestContainmentMatch != null) return bestContainmentMatch;

  final candidateIds = categories.map((c) => c.id).toList();
  final candidateLabels = candidateIds
      .map((id) => normalizedLabels[id]!)
      .toList();
  final result = StringSimilarity.findBestMatch(normalizedText, candidateLabels);
  if (result.bestMatch.rating == null ||
      result.bestMatch.rating! < fuzzyThreshold) {
    return null;
  }
  return candidateIds[result.bestMatchIndex];
}

/// Runs the full local (offline) parse — see [ParseQuickEntryUseCase] for
/// the orchestration that adds the cloud-LLM fallback on top of this.
QuickEntryParseResult parseQuickEntryTextLocally({
  required String text,
  required List<CategoryEntity> categories,
  required String Function(CategoryEntity) categoryLabels,
}) {
  return QuickEntryParseResult(
    amount: parseVietnameseAmount(text),
    categoryId: matchCategoryIdFromText(
      text: text,
      categories: categories,
      categoryLabels: categoryLabels,
    ),
  );
}
