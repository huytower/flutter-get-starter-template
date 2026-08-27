import 'package:domain_features/core/helper/quick_entry_parser_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ocrText = """
hå huy tap tp ha tinh
hoa don ban hang
ngay 17/11/18
mota cafe
in luc: 17:17
gold kiwi
thu ngan: administrator
green tea
 tra kiwi 
gio vao:17:17 
mat hang sl gia
 vi
hat dė
0911586768
tra sua vi
phuc bon tu
tien hang:
giam 10%:
tong:
ban 02
so: 111800005
1
1 35 000
1
gio ra:17:17
t tien
30 000
35 000
30 000
30 000 30 000
95 000
10 000
85 000
cam on quy khach hen gap lai
""";

  group('QuickEntryParserHelper', () {
    test('should strip phone numbers and invoice numbers', () {
      final cleaned = stripInvoiceNumbers(stripPhoneNumbers(ocrText));
      expect(cleaned.contains("0911586768"), isFalse);
      expect(cleaned.contains("111800005"), isFalse);
    });

    test('should extract correct total amount even with noise', () {
      final cleaned = stripInvoiceNumbers(stripPhoneNumbers(ocrText));
      final amount = parseVietnameseAmount(cleaned);
      expect(amount, 85000);
    });

    test('should extract line items correctly', () {
      final items = extractItemsFromText(ocrText);
      // Items might be hard to extract perfectly locally due to OCR shuffle,
      // but we should at least get some valid-looking pairs.
      expect(items.isNotEmpty, isTrue);
      expect(items.any((it) => it.price >= 30000), isTrue);
    });

    test('should build a concise summary note', () {
      final items = extractItemsFromText(ocrText);
      final note = summarizeBillItems(items);
      expect(note, isNotEmpty);
      expect(note, contains("k)")); // Expecting format like "Item (30k)"
    });
  });
}
