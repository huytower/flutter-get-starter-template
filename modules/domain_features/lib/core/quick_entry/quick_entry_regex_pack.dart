import 'quick_entry_regex_dataset.dart';

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

