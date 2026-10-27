import 'quick_entry_alias_dataset.dart';
import 'quick_entry_intent.dart';
import 'quick_entry_intent_util.dart';
import 'quick_entry_regex_dataset.dart';

/// Language-owned quick-entry content.
///
/// Keep parsing algorithms and numeric limits outside this class. A locale
/// pack should contain only words, labels, aliases, and language-sensitive
/// patterns. New regions can add a pack without changing parser logic.
class QuickEntryLocalePack {
  const QuickEntryLocalePack({
    required this.languageCode,
    required this.amountUnitMultipliers,
    required this.billStopWords,
    required this.noteFillerWords,
    required this.noteFieldLabels,
    required this.categoryFieldLabels,
    required this.categoryKeywords,
    required this.dateRelativeOffsets,
    required this.walletKeywords,
    required this.intentRoots,
    required this.directionalVerbs,
    required this.ambiguousContexts,
    required this.investmentReturnKeywords,
    required this.debtRepayKeywords,
    required this.lendCollectKeywords,
    required this.regex,
  });

  final String languageCode;
  final Map<String, int> amountUnitMultipliers;
  final Set<String> billStopWords;
  final Set<String> noteFillerWords;
  final List<String> noteFieldLabels;
  final List<String> categoryFieldLabels;
  final Map<String, String> categoryKeywords;
  final Map<String, int> dateRelativeOffsets;
  final Map<String, List<String>> walletKeywords;
  final Map<QuickEntryIntent, List<String>> intentRoots;
  final Map<String, QuickEntryIntent> directionalVerbs;
  final Map<String, Map<String, QuickEntryIntent>> ambiguousContexts;
  final List<String> investmentReturnKeywords;
  final List<String> debtRepayKeywords;
  final List<String> lendCollectKeywords;
  final QuickEntryRegexPack regex;

  /// Current Vietnamese dataset, retained as the compatibility baseline while
  /// the remaining locale packs are added incrementally.
  factory QuickEntryLocalePack.vietnamese() {
    return QuickEntryLocalePack(
      languageCode: 'vi',
      amountUnitMultipliers: QuickEntryAliasDataset.amountUnitMultipliers,
      billStopWords: QuickEntryAliasDataset.billStopWords,
      noteFillerWords: QuickEntryAliasDataset.noteFillerWords,
      noteFieldLabels: QuickEntryAliasDataset.noteFieldLabels,
      categoryFieldLabels: QuickEntryAliasDataset.categoryFieldLabels,
      categoryKeywords: QuickEntryAliasDataset.categoryKeywords,
      dateRelativeOffsets: QuickEntryAliasDataset.dateRelativeOffsets,
      walletKeywords: QuickEntryAliasDataset.walletKeywords,
      intentRoots: QuickEntryIntentUtil.intentRoots,
      directionalVerbs: QuickEntryIntentUtil.directionalVerbs,
      ambiguousContexts: QuickEntryIntentUtil.ambiguousContexts,
      investmentReturnKeywords: QuickEntryIntentUtil.investmentReturnKeywords,
      debtRepayKeywords: QuickEntryIntentUtil.debtRepayKeywords,
      lendCollectKeywords: QuickEntryIntentUtil.lendCollectKeywords,
      regex: QuickEntryRegexPack.vietnamese(),
    );
  }
}

/// Language-sensitive regular expressions owned by a locale pack.
class QuickEntryRegexPack {
  const QuickEntryRegexPack({
    required this.amountPattern,
    required this.invoiceNumberPattern,
    required this.phoneRegex,
    required this.addressRegex,
    required this.totalKeywords,
    required this.lineItemAmountPattern,
    required this.slashDateRegex,
    required this.localizedDateRegex,
    required this.ocrNoisePattern,
  });

  final RegExp amountPattern;
  final RegExp invoiceNumberPattern;
  final RegExp phoneRegex;
  final RegExp addressRegex;
  final RegExp totalKeywords;
  final RegExp lineItemAmountPattern;
  final RegExp slashDateRegex;
  final RegExp localizedDateRegex;
  final RegExp ocrNoisePattern;

  factory QuickEntryRegexPack.vietnamese() {
    return QuickEntryRegexPack(
      amountPattern: QuickEntryRegexDataset.amountPattern,
      invoiceNumberPattern: QuickEntryRegexDataset.invoiceNumberPattern,
      phoneRegex: QuickEntryRegexDataset.phoneRegex,
      addressRegex: QuickEntryRegexDataset.addressRegex,
      totalKeywords: QuickEntryRegexDataset.totalKeywords,
      lineItemAmountPattern: QuickEntryRegexDataset.lineItemAmountPattern,
      slashDateRegex: QuickEntryRegexDataset.slashDateRegex,
      localizedDateRegex: QuickEntryRegexDataset.vnDateRegex,
      ocrNoisePattern: QuickEntryRegexDataset.ocrNoisePattern,
    );
  }
}
