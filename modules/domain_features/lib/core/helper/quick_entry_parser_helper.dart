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

// Two alternatives in one capturing group: a properly-grouped thousands
// number (one-to-three leading digits, then one or more `.NNN`/`,NNN`
// groups of exactly 3 digits — e.g. "1.500.000", "50.000") is tried first,
// falling back to a single digit run with at most one trailing separator
// group of any length (covers plain "500000" and a decimal fraction before
// a unit like "1,5tr"). Without the first alternative, "1.500.000" was
// silently mis-parsed as 1500 — allMatches only ever consumes one `[.,]`
// group per match, splitting the rest off as a second, separate match.
final RegExp _amountPattern = RegExp(
  r'(\d{1,3}(?:[.,]\d{3})+|\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu|d|vnd)?',
);

/// Parses a Vietnamese money shorthand out of [text] — `50k`, `50.000`,
/// `1tr`, `1,5tr`, `500 nghin`, plain `500000`, with an optional `đ`/`vnd`
/// suffix. Returns null when nothing plausible is found. A bare number under
/// 1000 with no unit/currency suffix is treated as ambiguous (more likely a
/// stray digit than a real amount in this app's context) and returned as
/// null rather than guessed at.
///
/// Scans every number in [text], not just the first — natural "quantity +
/// item + price" phrasing (e.g. "2 ly cafe 50k") states an unmarked
/// quantity before the actual (unit-suffixed) price, so preferring the
/// *last* number that carries an explicit unit/currency suffix over the
/// first digit run avoids misreading the quantity as the amount.
///
/// Deliberately uses [stripVietnameseDiacritics] (lowercase + diacritics
/// only), not the full [normalizeMerchantText] — the latter also strips all
/// punctuation, which would delete the `.`/`,` decimal/thousands separators
/// this function's own regex depends on before the regex ever runs.
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

/// Common informal/English shorthand mapped straight to a seed category id
/// (see `CategorySeed`) — checked before the fuzzy label match below since
/// these words don't reliably fuzzy-match their formal Vietnamese label
/// (e.g. "cafe" vs. "cà phê" normalizes to "ca phe", a weak Dice's-
/// coefficient match). Deliberately small and hand-picked, same style as
/// [suggestExpenseCategoryIdForHour]'s hardcoded ids — not meant to be
/// exhaustive, the fuzzy fallback below covers everything else.
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

/// [_categoryKeywordAliases] sorted longest-key-first, computed once — a
/// shorter alias that's also a substring of a longer one (e.g. "dien" vs.
/// "dien thoai") must never win the match just because it's declared
/// earlier in the map; checking longest-first guarantees the more specific
/// alias is always tried before the substring it contains.
final List<MapEntry<String, String>> _sortedCategoryKeywordAliases =
    _categoryKeywordAliases.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

/// Best-effort local category match for [text] among [categories] — checks
/// the hand-picked alias table first, then substring containment against
/// each category's live label (`el.tr(category.nameKey)`, passed in via
/// [categoryLabels] since this helper is pure/untestable-with-locale
/// otherwise), then falls back to fuzzy matching (same `string_similarity`
/// dependency as [findBestMerchantMatch]). Returns null when nothing is
/// confident enough.
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
