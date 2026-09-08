import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../features/category/domain/entities/category_entity.dart';
import '../../features/wallet/domain/entities/wallet_entity.dart';
import 'merchant_match_helper.dart';
import 'quick_entry_alias_dataset.dart';
import 'quick_entry_parse_result.dart';
import 'quick_entry_regex_dataset.dart';

export 'quick_entry_parse_result.dart';

const Map<String, int> _amountUnitMultipliers =
    QuickEntryAliasDataset.amountUnitMultipliers;

final RegExp _amountPattern = QuickEntryRegexDataset.amountPattern;

/// Matches common Vietnamese invoice/serial number prefixes followed by digits.
final RegExp invoiceNumberPattern = QuickEntryRegexDataset.invoiceNumberPattern;

/// Strips Vietnamese phone numbers from [text].
/// Optimized for "0..." and "+84..." patterns.
String stripPhoneNumbers(String text) {
  var result = text;
  final phoneRegex = QuickEntryRegexDataset.phoneRegex;
  final matches = phoneRegex.allMatches(text);

  for (final match in matches) {
    final potential = match.group(0)!;
    try {
      final parsed = PhoneNumber.parse(potential, callerCountry: IsoCode.VN);
      if (parsed.isValid(type: PhoneNumberType.mobile)) {
        '[AI_PARSING] [LOCAL] 🚫 Phone number stripped | "$potential"'.Log(
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
    '[AI_PARSING] [LOCAL] 🚫 Serial/invoice number stripped | "$stripped"'.Log(
      'QuickEntryParserHelper',
    );
    return ' ';
  });
}

int? parseVietnameseAmount(String text) {
  final normalized = stripVietnameseDiacritics(text.toLowerCase());

  // 1. Identify and temporarily mask potential address/non-amount numbers
  final addressRegex = QuickEntryRegexDataset.addressRegex;

  // Mask address numbers with spaces to avoid them being grouped into amounts
  // e.g., "quan 1 100k" -> "       100k"
  final amountCleanedText = normalized.replaceAllMapped(addressRegex, (match) {
    return ' ' * match.group(0)!.length;
  });

  // 2. Collect all valid amounts from the masked text
  final matches = _amountPattern.allMatches(amountCleanedText).toList();
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
      // Use 1 billion constant indirectly via dataset or hardcoded threshold check
      if (value >= QuickEntryAliasDataset.minPlausibleAmount &&
          value < QuickEntryAliasDataset.maxLocalTotalAmount) {
        amounts.add(value);
      }
    }
  }

  if (amounts.isEmpty) return null;

  // 3. Check for explicit "Total" keywords in the text
  final totalKeywords = QuickEntryRegexDataset.totalKeywords;

  final hasTotalKeyword = totalKeywords.hasMatch(normalized);

  if (hasTotalKeyword) {
    // If multiple amounts exist on a line with a total keyword, take the last one on that line.
    final lines = normalized.split('\n');
    for (int i = lines.length - 1; i >= 0; i--) {
      if (totalKeywords.hasMatch(lines[i])) {
        // Use masked text for matches within the line to avoid address numbers
        final lineText = amountCleanedText.split('\n')[i];
        final lineMatches = _amountPattern.allMatches(lineText).toList();
        if (lineMatches.isNotEmpty) {
          final numeric = lineMatches.last.group(1)!;
          final unit = lineMatches.last.group(2);
          final digitsOnly = numeric.replaceAll(RegExp('[., ]'), '');
          var value = int.tryParse(digitsOnly);
          if (value != null) {
            if (unit != null) {
              final multiplier = _amountUnitMultipliers[unit.toLowerCase()];
              if (multiplier != null && multiplier > 1) {
                value *= multiplier;
              }
            }
            if (value >= QuickEntryAliasDataset.minPlausibleAmount)
              return value;
          }
        }
      }
    }
    // Fallback: take the last large amount in the entire text
    return amounts.last;
  }

  // 4. Fallback: prefer the last amount with an explicit unit (like 'k' or 'tr')
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
  final amountPattern = QuickEntryRegexDataset.lineItemAmountPattern;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final match = amountPattern.allMatches(line).lastOrNull;
    if (match == null) continue;

    final numeric = match.group(1)!;
    final unit = match.group(2);
    final digitsOnly = numeric.replaceAll(RegExp('[., ]'), '');
    var value = int.tryParse(digitsOnly);

    if (value == null ||
        value < QuickEntryAliasDataset.minPlausibleAmount ||
        value > QuickEntryAliasDataset.maxLineItemAmount)
      continue;

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

    // Ignore items that are just punctuation or repeated zeros (OCR artifacts)
    final isNoise =
        name.isEmpty ||
        QuickEntryRegexDataset.ocrNoisePattern.hasMatch(name) ||
        name.length < 2;

    if (!isNoise && !_isStopWord(name)) {
      items.add((name: name, price: value));
    }
  }

  return items;
}

bool _isStopWord(String text) {
  final lower = stripVietnameseDiacritics(text.toLowerCase());
  return QuickEntryAliasDataset.billStopWords.any(
    (s) => lower.startsWith(s) || lower.endsWith(s),
  );
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

const Map<String, String> _categoryKeywordAliases =
    QuickEntryAliasDataset.categoryKeywords;

/// High-level intent categories based on Vietnamese keywords.
enum QuickEntryIntent { expense, income, investment, debt, lend }

QuickEntryIntent? detectQuickEntryIntent(String text) {
  final normalized = stripVietnameseDiacritics(text.toLowerCase());

  // 1. Check for high-priority root intents (e.g., "đầu tư", "income")
  for (final entry in QuickEntryAliasDataset.intentRoots.entries) {
    for (final keyword in entry.value) {
      if (normalized.contains(keyword)) {
        '[AI_PARSING] [LOCAL] 🎯 Intent root matched: "$keyword" -> ${entry.key}'
            .Log('QuickEntryParserHelper');
        return entry.key;
      }
    }
  }

  // 2. Identify the primary direction of the action (Inflow vs. Outflow)
  QuickEntryIntent? detectedDirection;
  String? matchedVerb;
  for (final verbEntry in QuickEntryAliasDataset.directionalVerbs.entries) {
    if (normalized.contains(verbEntry.key)) {
      detectedDirection = verbEntry.value;
      matchedVerb = verbEntry.key;
      // Continue to find the longest matching verb (e.g., "cho vay" vs. "vay")
    }
  }
  if (detectedDirection != null) {
    '[AI_PARSING] [LOCAL] 🎯 Direction matched: "$matchedVerb" -> $detectedDirection'
        .Log('QuickEntryParserHelper');
  }

  // 3. Category Hint Detection: If no explicit direction or root is found,
  // check if any category-specific keywords are present (e.g., "luong", "lam them").
  if (detectedDirection == null) {
    for (final aliasEntry in _sortedCategoryKeywordAliases) {
      final pattern = aliasEntry.key.length <= 3
          ? RegExp('\\b${RegExp.escape(aliasEntry.key)}\\b')
          : RegExp(RegExp.escape(aliasEntry.key));

      if (pattern.hasMatch(normalized)) {
        final catId = aliasEntry.value;
        final QuickEntryIntent? hint;
        if (catId.startsWith('i')) {
          hint = QuickEntryIntent.income;
        } else if (catId.startsWith('inv')) {
          hint = QuickEntryIntent.investment;
        } else if (catId == 'd6' || catId == 'd8') {
          hint = QuickEntryIntent.lend;
        } else if (catId.startsWith('d')) {
          hint = QuickEntryIntent.debt;
        } else if (catId.startsWith('c')) {
          hint = QuickEntryIntent.expense;
        } else {
          hint = null;
        }

        if (hint != null) {
          '[AI_PARSING] [LOCAL] 💡 Category hint detected: "${aliasEntry.key}" ($catId) -> $hint'
              .Log('QuickEntryParserHelper');
          return hint;
        }
      }
    }
  }

  // 4. Smart Intent Override: If "mua" (buy) is followed by an investment category,
  // it's likely an investment contribution, not a personal expense.
  if (detectedDirection == QuickEntryIntent.expense &&
      normalized.contains('mua')) {
    for (final keyword in QuickEntryAliasDataset.categoryKeywords.entries) {
      if (normalized.contains(keyword.key) && keyword.value.startsWith('inv')) {
        '[AI_PARSING] [LOCAL] 🔄 Smart override: "mua" + investment category -> investment'
            .Log('QuickEntryParserHelper');
        return QuickEntryIntent.investment;
      }
    }
  }

  // 5. Resolve ambiguous contexts (like "lì xì" or "vay")
  for (final contextEntry in QuickEntryAliasDataset.ambiguousContexts.entries) {
    final pattern = contextEntry.key.length <= 2
        ? RegExp('\\b${RegExp.escape(contextEntry.key)}\\b')
        : RegExp(RegExp.escape(contextEntry.key));

    if (pattern.hasMatch(normalized)) {
      if (detectedDirection == null) {
        final result = contextEntry.value['default']!;
        '[AI_PARSING] [LOCAL] 🎯 Ambiguous context (default): "${contextEntry.key}" -> $result'
            .Log('QuickEntryParserHelper');
        return result;
      }

      final isInflow =
          detectedDirection == QuickEntryIntent.income ||
          detectedDirection == QuickEntryIntent.debt;

      final result = isInflow
          ? contextEntry.value['inflow']!
          : contextEntry.value['outflow']!;

      '[AI_PARSING] [LOCAL] 🎯 Ambiguous context resolved: "${contextEntry.key}" (direction: $detectedDirection) -> $result'
          .Log('QuickEntryParserHelper');
      return result;
    }
  }

  // Final fallback to the detected direction
  return detectedDirection;
}

const int _minCategoryQueryLength = 2;

final List<MapEntry<String, String>> _sortedCategoryKeywordAliases =
    _categoryKeywordAliases.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

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
    final pattern = aliasEntry.key.length <= 3
        ? RegExp('\\b${RegExp.escape(aliasEntry.key)}\\b')
        : RegExp(RegExp.escape(aliasEntry.key));

    if (pattern.hasMatch(normalizedText) &&
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

String? _extractLabeledFieldValue(String text, List<String> labels) {
  final originalLines = text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  if (originalLines.isEmpty) return null;
  final normalizedLines = originalLines.map(stripVietnameseDiacritics).toList();

  for (final label in labels) {
    for (int i = 0; i < normalizedLines.length; i++) {
      final idx = normalizedLines[i].indexOf(label);
      if (idx == -1) continue;

      final afterLabel = idx + label.length;
      final inline = afterLabel < originalLines[i].length
          ? originalLines[i]
                .substring(afterLabel)
                .replaceFirst(RegExp(r'^\s*[:\-]\s*'), '')
                .trim()
          : '';
      if (inline.length >= 2) return inline;

      // Label and value are on separate lines on some screenshot layouts.
      if (i + 1 < originalLines.length) {
        final next = originalLines[i + 1].trim();
        if (next.length >= 2) return next;
      }
    }
  }
  return null;
}

QuickEntryParseResult parseQuickEntryTextLocally({
  required String text,
  required List<CategoryEntity> categories,
  required String Function(CategoryEntity) categoryLabels,
  List<WalletEntity>? wallets,
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
  // 2a. Slash/Dash date patterns: "20/08", "20-08-2026"
  final slashDateMatch = QuickEntryRegexDataset.slashDateRegex.firstMatch(
    normalized,
  );
  if (slashDateMatch != null) {
    final day = int.tryParse(slashDateMatch.group(1) ?? '');
    final month = int.tryParse(slashDateMatch.group(2) ?? '');
    final yearStr = slashDateMatch.group(3);

    if (day != null && month != null) {
      int year = date.year;
      if (yearStr != null) {
        final y = int.tryParse(yearStr);
        if (y != null) {
          year = y < 100 ? 2000 + y : y;
        }
      }

      try {
        date = DateTime(year, month, day);
      } catch (_) {}
    }
    residual = residual.replaceFirst(slashDateMatch.group(0)!, '');
  } else {
    // 2b. Specific Vietnamese date patterns: "ngay 20", "ngay 20 thang 8", "ngay 20 thang nay"
    final vnDateMatch = QuickEntryRegexDataset.vnDateRegex.firstMatch(
      normalized,
    );
    if (vnDateMatch != null) {
      final day = int.tryParse(vnDateMatch.group(1) ?? '');
      final monthStr = vnDateMatch.group(2);

      if (day != null && day >= 1 && day <= 31) {
        int month = date.month;
        int year = date.year;

        if (monthStr != null && monthStr != 'nay') {
          final m = int.tryParse(monthStr);
          if (m != null && m >= 1 && m <= 12) {
            month = m;
          }
        }

        try {
          final potentialDate = DateTime(year, month, day);
          // If the date is in the future, it's likely previous month/year
          if (potentialDate.isAfter(DateTime.now())) {
            date = DateTime(year, month - 1, day);
          } else {
            date = potentialDate;
          }
        } catch (_) {}
      }
      residual = residual.replaceFirst(vnDateMatch.group(0)!, '');
    } else {
      // 2c. Relative date offsets: "hom qua", "today", etc.
      const dateOffsets = QuickEntryAliasDataset.dateRelativeOffsets;
      for (final offsetEntry in dateOffsets.entries) {
        if (normalized.contains(offsetEntry.key)) {
          date = date.subtract(Duration(days: offsetEntry.value));
          residual = residual.replaceFirst(offsetEntry.key, '');
          break;
        }
      }
    }
  }

  final isOcrText = text.contains('\n');

  String? matchedCategoryId;
  if (!isOcrText) {
    // Use word boundaries for short aliases to avoid partial matches
    for (final aliasEntry in _sortedCategoryKeywordAliases) {
      final pattern = aliasEntry.key.length <= 3
          ? RegExp('\\b${RegExp.escape(aliasEntry.key)}\\b')
          : RegExp(RegExp.escape(aliasEntry.key));

      if (pattern.hasMatch(normalized) &&
          categories.any((category) => category.id == aliasEntry.value)) {
        matchedCategoryId = aliasEntry.value;
        residual = residual.replaceFirst(aliasEntry.key, '');
        break;
      }
    }

    // 4. Fallback category matching if not found by alias
    matchedCategoryId ??= matchCategoryIdFromText(
      text: text,
      categories: categories,
      categoryLabels: categoryLabels,
    );
  }

  // 4b. Match Wallet (Source/Receiving)
  String? matchedWalletId;
  if (wallets != null && wallets.isNotEmpty) {
    for (final wallet in wallets) {
      final keywords = QuickEntryAliasDataset.walletKeywords[wallet.type];
      if (keywords != null) {
        for (final keyword in keywords) {
          if (normalized.contains(keyword)) {
            matchedWalletId = wallet.id;
            break;
          }
        }
      }
      if (matchedWalletId != null) break;

      // Fallback: match by wallet name (normalized)
      final name = stripVietnameseDiacritics(wallet.name.toLowerCase());
      if (normalized.contains(name)) {
        matchedWalletId = wallet.id;
        break;
      }
    }
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
      .where(
        (s) =>
            s.isNotEmpty &&
            (s.length > 1 || RegExp(r'\d').hasMatch(s)) &&
            !QuickEntryAliasDataset.noteFillerWords.contains(s),
      )
      .join(' ')
      .trim();

  String? finalNote = isOcrText
      ? _extractLabeledFieldValue(text, QuickEntryAliasDataset.noteFieldLabels)
      : (residualNote.isEmpty ? null : residualNote);
  if (isOcrText) {
    final labeledCategoryText = _extractLabeledFieldValue(
      text,
      QuickEntryAliasDataset.categoryFieldLabels,
    );
    if (labeledCategoryText != null) {
      matchedCategoryId = matchCategoryIdFromText(
        text: labeledCategoryText,
        categories: categories,
        categoryLabels: categoryLabels,
      );
    }
  }

  return QuickEntryParseResult(
    amount: parseVietnameseAmount(cleaned),
    categoryId: matchedCategoryId,
    walletId: matchedWalletId,
    date: date,
    note: finalNote,
  );
}
