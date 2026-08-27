import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../features/category/domain/entities/category_entity.dart';
import 'merchant_match_helper.dart';
import 'quick_entry_alias_dataset.dart';
import 'quick_entry_parse_result.dart';

export 'quick_entry_parse_result.dart';

const int _thousand = 1000;
const int _million = 1000000;
const int _billion = 1000000000;

final Map<String, int> _amountUnitMultipliers = {
  'k': _thousand,
  'nghin': _thousand,
  'tr': _million,
  'trieu': _million,
  'ty': _billion,
  'b': _billion,
  'd': 1,
  'vnd': 1,
  'dong': 1,
};

// Grouped-thousands form (e.g. "1.500.000" or "85 000") is tried before
// the plain digit-run fallback.
// Units like 'tr' (million) use negative lookahead to avoid matching
// prefixes in words like 'tra' (tea).
final RegExp _amountPattern = RegExp(
  r'(\d{1,3}(?:[., ]\d{3})+|\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu|ty|b|d|vnd|dong)?(?!\w)',
);

/// Matches common Vietnamese invoice/serial number prefixes followed by digits.
final RegExp invoiceNumberPattern = RegExp(
  r'(?:s[oô]|so|invoice|no|ma\s*hd|hd)\s*:?\s*[a-z0-9-]{4,20}',
  caseSensitive: false,
);

/// Strips Vietnamese phone numbers from [text].
/// Optimized for "0..." and "+84..." patterns.
String stripPhoneNumbers(String text) {
  var result = text;
  final phoneRegex = RegExp(r'(?:\+84|0)\d{9,10}');
  final matches = phoneRegex.allMatches(text);

  for (final match in matches) {
    final potential = match.group(0)!;
    try {
      final parsed = PhoneNumber.parse(potential, callerCountry: IsoCode.VN);
      if (parsed.isValid(type: PhoneNumberType.mobile)) {
        '[AI_PARSING] 🚫 Phone number stripped | "$potential"'.Log(
          'QuickEntryParserHelper',
        );
        result = result.replaceFirst(potential, ' ');
      }
    } catch (_) {
      // Not a valid phone number, keep it.
    }
  }
  return result;
}

/// Strips invoice/serial numbers from [text].
String stripInvoiceNumbers(String text) {
  return text.replaceAllMapped(invoiceNumberPattern, (match) {
    final stripped = match.group(0)!;
    '[AI_PARSING] 🚫 Serial/invoice number stripped | "$stripped"'.Log(
      'QuickEntryParserHelper',
    );
    return ' ';
  });
}

/// Parses a Vietnamese money shorthand out of [text] — `50k`, `50.000`,
/// `1tr`, `1,5tr`, `500 nghin`, plain `500000`, optional `đ`/`vnd` suffix.
/// Null if nothing plausible (a bare number under 1000 with no unit is
/// treated as ambiguous, not guessed at).
///
/// Prefers "Tổng" (Total) amount if multiple amounts are found.
/// Otherwise, prefers the *last* number carrying an explicit unit/currency
/// suffix over the first digit run.
int? parseVietnameseAmount(String text) {
  final normalized = stripVietnameseDiacritics(text.toLowerCase());

  // 1. Collect all valid amounts from the text
  final matches = _amountPattern.allMatches(normalized).toList();
  if (matches.isEmpty) return null;

  final amounts = <int>[];
  for (final match in matches) {
    final numeric = match.group(1)!;
    final unit = match.group(2);
    final digitsOnly = numeric.replaceAll(RegExp('[., ]'), '');
    var value = int.tryParse(digitsOnly);

    if (value != null) {
      if (unit != null) {
        final multiplier = _amountUnitMultipliers[unit.toLowerCase()];
        if (multiplier != null && multiplier > 1) {
          value *= multiplier;
        }
      }
      if (value >= 1000 && value < _billion) {
        amounts.add(value);
      }
    }
  }

  if (amounts.isEmpty) return null;

  // 2. Check for explicit "Total" keywords in the text
  final hasTotalKeyword = RegExp(
    r'tong|thanh\s*toan|total|t\s*tien',
  ).hasMatch(normalized);

  if (hasTotalKeyword) {
    // On a receipt, the Grand Total is almost always the LAST large amount,
    // even if the OCR is shuffled.
    // We filter out suspiciously small amounts (like tips or quantities)
    // and take the last one.
    return amounts.last;
  }

  // 3. Fallback: prefer the last amount with an explicit unit (like 'k' or 'tr')
  RegExpMatch? lastWithUnit;
  for (final match in matches) {
    if (match.group(2) != null) lastWithUnit = match;
  }

  if (lastWithUnit != null) {
    final numeric = lastWithUnit.group(1)!;
    final unit = lastWithUnit.group(2)!;
    final digitsOnly = numeric.replaceAll(RegExp('[., ]'), '');
    final value = int.tryParse(digitsOnly);
    if (value != null) {
      final multiplier = _amountUnitMultipliers[unit.toLowerCase()] ?? 1;
      return value * multiplier;
    }
  }

  return amounts.last;
}

/// Identifies likely line items (name + price) in a bill OCR string.
List<({String name, int price})> extractItemsFromText(String text) {
  final cleaned = stripInvoiceNumbers(stripPhoneNumbers(text));
  final lines = cleaned
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  final items = <({String name, int price})>[];
  final amountPattern = RegExp(
    r'([\d. ,]+)\s*(k|nghin|tr|trieu|vnd|d|dong)?(?!\w)',
  );

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final match = amountPattern.allMatches(line).lastOrNull;
    if (match == null) continue;

    final numeric = match.group(1)!;
    final unit = match.group(2);
    final digitsOnly = numeric.replaceAll(RegExp('[., ]'), '');
    var value = int.tryParse(digitsOnly);

    if (value == null || value < 1000 || value > 10000000) continue;

    if (unit != null) {
      final multiplier = _amountUnitMultipliers[unit.toLowerCase()];
      if (multiplier != null && multiplier > 1) {
        value *= multiplier;
      }
    }

    // Item name is usually on the same line or previous line
    var name = line.substring(0, match.start).trim();
    if (name.length < 3 && i > 0) {
      name = lines[i - 1];
    }

    // Clean name from quantities or separators
    name = name
        .replaceAll(RegExp(r'^\d+\s*'), '') // Remove leading quantity
        .replaceAll(RegExp(r'[|:;]'), '')
        .trim();

    if (name.length >= 3 && !_isStopWord(name)) {
      items.add((name: name, price: value));
    }
  }

  return items;
}

bool _isStopWord(String text) {
  final lower = stripVietnameseDiacritics(text.toLowerCase());
  const stopWords = {
    'tong',
    't tien',
    'thanh tien',
    'tien hang',
    'giam',
    'chiet khau',
    'thue',
    'vat',
    'phi',
    'phu phi',
    'thanh toan',
    'khach tra',
    'tra lai',
  };
  return stopWords.any((s) => lower.startsWith(s) || lower.endsWith(s));
}

/// Summarizes extracted items into a single string for the note field.
String summarizeBillItems(List<({String name, int price})> items) {
  if (items.isEmpty) return '';
  return items
      .map((it) {
        final priceK = (it.price / 1000).toStringAsFixed(0);
        return '${it.name} (${priceK}k)';
      })
      .join(', ');
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
  // Clean noise first
  final cleaned = stripInvoiceNumbers(stripPhoneNumbers(text));
  final normalized = stripVietnameseDiacritics(cleaned.toLowerCase());
  DateTime date = DateTime.now();
  String residual = normalized;

  // 1. Extract Amount and remove from residual
  final amountMatch = _amountPattern.firstMatch(normalized);
  if (amountMatch != null) {
    residual = residual.replaceFirst(amountMatch.group(0)!, '');
  }

  // 2. Extract Date and remove from residual
  final dateOffsets = QuickEntryAliasDataset.dateRelativeOffsets;
  for (final offsetEntry in dateOffsets.entries) {
    if (normalized.contains(offsetEntry.key)) {
      date = date.subtract(Duration(days: offsetEntry.value));
      residual = residual.replaceFirst(offsetEntry.key, '');
      break;
    }
  }

  // 3. Match Category and remove matched alias from residual
  String? matchedCategoryId;
  for (final aliasEntry in _sortedCategoryKeywordAliases) {
    if (normalized.contains(aliasEntry.key) &&
        categories.any((category) => category.id == aliasEntry.value)) {
      matchedCategoryId = aliasEntry.value;
      residual = residual.replaceFirst(aliasEntry.key, '');
      break;
    }
  }

  // 4. Fallback category matching if not found by alias
  if (matchedCategoryId == null) {
    matchedCategoryId = matchCategoryIdFromText(
      text: text,
      categories: categories,
      categoryLabels: categoryLabels,
    );
  }

  // 5. Remove Intent roots and directional verbs from residual
  for (final rootKeywords in QuickEntryAliasDataset.intentRoots.values) {
    for (final keyword in rootKeywords) {
      residual = residual.replaceFirst(keyword, '');
    }
  }
  for (final verb in QuickEntryAliasDataset.directionalVerbs.keys) {
    residual = residual.replaceFirst(verb, '');
  }

  // 6. Clean up residual text to get the final note
  // Remove common filler words and extra spaces/punctuation
  final residualNote = residual
      .replaceAll(RegExp(r'[.,\-–()]'), ' ')
      .split(' ')
      .where((s) => s.isNotEmpty && s.length > 1)
      .join(' ')
      .trim();

  // 7. If this is an OCR string (contains newlines) and has items, build a better note
  String? finalNote = residualNote.isEmpty ? null : residualNote;
  if (text.contains('\n')) {
    final items = extractItemsFromText(text);
    if (items.isNotEmpty) {
      finalNote = summarizeBillItems(items);
    }
  }

  return QuickEntryParseResult(
    amount: parseVietnameseAmount(cleaned),
    categoryId: matchedCategoryId,
    date: date,
    note: finalNote,
  );
}
