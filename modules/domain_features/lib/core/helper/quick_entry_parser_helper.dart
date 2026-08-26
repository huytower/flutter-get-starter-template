import 'package:string_similarity/string_similarity.dart';

import '../../features/category/domain/entities/category_entity.dart';
import 'merchant_match_helper.dart';
import 'quick_entry_alias_dataset.dart';
import 'quick_entry_parse_result.dart';

export 'quick_entry_parse_result.dart';

const int _thousand = 1000;
const int _million = 1000000;

final Map<String, int> _amountUnitMultipliers = {
  'k': _thousand,
  'nghin': _thousand,
  'tr': _million,
  'trieu': _million,
  'd': 1,
  'vnd': 1,
  'dong': 1,
};

// Grouped-thousands form (e.g. "1.500.000") is tried before the plain
// digit-run fallback — without it, "1.500.000" mis-parsed as 1500, since
// allMatches only consumes one `[.,]` group per match.
final RegExp _amountPattern = RegExp(
  r'(\d{1,3}(?:[.,]\d{3})+|\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu|d|vnd|dong)?',
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
  for (final match in matches) {
    if (match.group(2) != null) lastWithUnit = match;
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

  if (unit == 'd' || unit == 'vnd' || unit == 'dong') {
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
const Map<String, String> _categoryKeywordAliases =
    QuickEntryAliasDataset.categoryKeywords;

/// High-level intent categories based on Vietnamese keywords.
enum QuickEntryIntent { expense, income, investment, debt, lend }

/// Detects the user's intent based on common Vietnamese and English action
/// verbs and prefixes — e.g. "nhận tiền", "income" implies Income,
/// regardless of the specific category keyword.
QuickEntryIntent? detectQuickEntryIntent(String text) {
  final normalized = stripVietnameseDiacritics(text.toLowerCase());

  // 1. Check for high-priority root intents (e.g., "đầu tư", "income")
  for (final entry in QuickEntryAliasDataset.intentRoots.entries) {
    if (entry.value.any((keyword) => normalized.contains(keyword))) {
      return entry.key;
    }
  }

  // 2. Identify the primary direction of the action (Inflow vs. Outflow)
  QuickEntryIntent? detectedDirection;
  for (final verbEntry in QuickEntryAliasDataset.directionalVerbs.entries) {
    if (normalized.contains(verbEntry.key)) {
      detectedDirection = verbEntry.value;
      // Continue to find the longest matching verb (e.g., "cho vay" vs. "vay")
    }
  }

  // 3. Resolve ambiguous contexts (like "lì xì" or "vay")
  for (final contextEntry in QuickEntryAliasDataset.ambiguousContexts.entries) {
    if (normalized.contains(contextEntry.key)) {
      if (detectedDirection == null) {
        return contextEntry.value['default'];
      }

      final isInflow =
          detectedDirection == QuickEntryIntent.income ||
          detectedDirection == QuickEntryIntent.debt;

      return isInflow
          ? contextEntry.value['inflow']
          : contextEntry.value['outflow'];
    }
  }

  // 4. Final fallback to the detected direction
  return detectedDirection;
}

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

  for (final aliasEntry in _sortedCategoryKeywordAliases) {
    if (normalizedText.contains(aliasEntry.key) &&
        categories.any((category) => category.id == aliasEntry.value)) {
      return aliasEntry.value;
    }
  }

  final normalizedLabels = {
    for (final category in categories)
      category.id: normalizeMerchantText(categoryLabels(category)),
  };

  String? bestContainmentMatch;
  int bestContainmentLength = 0;
  for (final category in categories) {
    final label = normalizedLabels[category.id]!;
    if (label.isEmpty) continue;
    if (normalizedText.contains(label) &&
        label.length > bestContainmentLength) {
      bestContainmentMatch = category.id;
      bestContainmentLength = label.length;
    }
  }
  if (bestContainmentMatch != null) return bestContainmentMatch;

  final candidateIds = categories.map((category) => category.id).toList();
  final candidateLabels = candidateIds
      .map((categoryId) => normalizedLabels[categoryId]!)
      .toList();
  final matchResult = StringSimilarity.findBestMatch(
    normalizedText,
    candidateLabels,
  );
  if (matchResult.bestMatch.rating == null ||
      matchResult.bestMatch.rating! < fuzzyThreshold) {
    return null;
  }
  return candidateIds[matchResult.bestMatchIndex];
}

/// Runs the full local (offline) parse — see [ParseQuickEntryUseCase] for
/// the orchestration that adds the cloud-LLM fallback on top of this.
QuickEntryParseResult parseQuickEntryTextLocally({
  required String text,
  required List<CategoryEntity> categories,
  required String Function(CategoryEntity) categoryLabels,
}) {
  final normalized = stripVietnameseDiacritics(text.toLowerCase());
  DateTime date = DateTime.now();

  final dateOffsets = QuickEntryAliasDataset.dateRelativeOffsets;
  for (final offsetEntry in dateOffsets.entries) {
    if (normalized.contains(offsetEntry.key)) {
      date = date.subtract(Duration(days: offsetEntry.value));
      break;
    }
  }

  return QuickEntryParseResult(
    amount: parseVietnameseAmount(text),
    categoryId: matchCategoryIdFromText(
      text: text,
      categories: categories,
      categoryLabels: categoryLabels,
    ),
    date: date,
  );
}
