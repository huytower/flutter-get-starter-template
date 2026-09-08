/// Centralized dataset of Regular Expressions for the local quick-entry parser.
class QuickEntryRegexDataset {
  QuickEntryRegexDataset._();

  /// Grouped-thousands form (e.g. "1.500.000" or "85 000") is tried before
  /// the plain digit-run fallback.
  static final RegExp amountPattern = RegExp(
    r'(\d{1,3}(?:[., ]\d{3})+|\d+(?:[.,]\d+)?)\s*(k|nghin|trieudong|trieu|tr|ty|b|vnd|dong|d)?(?!\w)',
  );

  /// Matches common Vietnamese invoice/serial number prefixes followed by digits.
  static final RegExp invoiceNumberPattern = RegExp(
    r'(?:s[oô]|so|invoice|no|ma\s*hd|hd)\s*:?\s*[a-z0-9-]{4,20}',
    caseSensitive: false,
  );

  /// Strips Vietnamese phone numbers. Optimized for "0..." and "+84..." patterns.
  static final RegExp phoneRegex = RegExp(r'(?:\+84|0)\d{9,10}');

  /// Keywords that identify potential address/non-amount numbers to be masked during amount parsing.
  static const String addressKeywords =
      r'q|quan|p|phuong|duong|so|ngo|ngach|hem|kiet|dist|no|lo|can';

  /// Regex to identify and temporarily mask potential address/non-amount numbers.
  static final RegExp addressRegex = RegExp(
    '\\b($addressKeywords)\\s*\\d+\\b',
    caseSensitive: false,
  );

  /// Matches "Total" related keywords to identify the grand total on a receipt.
  static final RegExp totalKeywords = RegExp(
    r'tong|thanh\s*toan|total|t\s*tien|grand\s*total|sum',
    caseSensitive: false,
  );

  /// Item name + price extractor for line-by-line OCR parsing.
  static final RegExp lineItemAmountPattern = RegExp(
    r'([\d. ,]+)\s*(k|nghin|tr|trieu|vnd|d|dong)?(?!\w)',
  );

  /// Slash or Dash date patterns: "20/08", "20-08-2026".
  static final RegExp slashDateRegex = RegExp(
    r'(\d{1,2})[/-](\d{1,2})(?:[/-](\d{2,4}))?',
  );

  /// Specific Vietnamese date patterns: "ngay 20", "ngay 20 thang 8", "ngay 20 thang nay".
  static final RegExp vnDateRegex = RegExp(
    r'ngay\s+(\d{1,2})(?:\s+thang\s+(\d{1,2}|nay))?',
    caseSensitive: false,
  );

  /// Alphanumeric cleaning regex.
  static final RegExp nonAlphanumeric = RegExp(r'[^a-z0-9\s]');

  /// Extra whitespace cleaning regex.
  static final RegExp extraWhitespace = RegExp(r'\s+');

  /// Noise detector for OCR artifacts (punctuation or repeated zeros).
  static final RegExp ocrNoisePattern = RegExp(r'^[.0O\s]+$');
}
