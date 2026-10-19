import 'quick_entry_regex_dataset.dart';

const Map<String, String> _vietnameseDiacriticsMap = {
  'à': 'a',
  'á': 'a',
  'ạ': 'a',
  'ả': 'a',
  'ã': 'a',
  'â': 'a',
  'ầ': 'a',
  'ấ': 'a',
  'ậ': 'a',
  'ẩ': 'a',
  'ẫ': 'a',
  'ă': 'a',
  'ằ': 'a',
  'ắ': 'a',
  'ặ': 'a',
  'ẳ': 'a',
  'ẵ': 'a',
  'è': 'e',
  'é': 'e',
  'ẹ': 'e',
  'ẻ': 'e',
  'ẽ': 'e',
  'ê': 'e',
  'ề': 'e',
  'ế': 'e',
  'ệ': 'e',
  'ể': 'e',
  'ễ': 'e',
  'ì': 'i',
  'í': 'i',
  'ị': 'i',
  'ỉ': 'i',
  'ĩ': 'i',
  'ò': 'o',
  'ó': 'o',
  'ọ': 'o',
  'ỏ': 'o',
  'õ': 'o',
  'ô': 'o',
  'ồ': 'o',
  'ố': 'o',
  'ộ': 'o',
  'ổ': 'o',
  'ỗ': 'o',
  'ơ': 'o',
  'ờ': 'o',
  'ớ': 'o',
  'ợ': 'o',
  'ở': 'o',
  'ỡ': 'o',
  'ù': 'u',
  'ú': 'u',
  'ụ': 'u',
  'ủ': 'u',
  'ũ': 'u',
  'ư': 'u',
  'ừ': 'u',
  'ứ': 'u',
  'ự': 'u',
  'ử': 'u',
  'ữ': 'u',
  'ỳ': 'y',
  'ý': 'y',
  'ỵ': 'y',
  'ỷ': 'y',
  'ỹ': 'y',
  'đ': 'd',
};

/// Lowercases and strips Vietnamese diacritics only — punctuation (incl.
/// `.`/`,`) is left untouched. Split out from [normalizeMerchantText] so
/// callers that still need punctuation preserved (e.g. `quick_entry_parser
/// _helper.dart`'s amount regex, which relies on `.`/`,` surviving as
/// decimal/thousands separators) don't have to reimplement the diacritics
/// map.
String stripVietnameseDiacritics(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_vietnameseDiacriticsMap[ch] ?? ch);
  }
  return buffer.toString();
}

/// Lowercases, strips Vietnamese diacritics and punctuation, and collapses
/// whitespace — so "Trà sữa Phúc Long!" and "tra sua phuc long" normalize to
/// the same comparable string before fuzzy matching.
String normalizeMerchantText(String input) {
  return stripVietnameseDiacritics(input)
      .replaceAll(QuickEntryRegexDataset.nonAlphanumeric, ' ')
      .replaceAll(QuickEntryRegexDataset.extraWhitespace, ' ')
      .trim();
}
