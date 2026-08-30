import 'package:domain_features/core/helper/quick_entry_parser_helper.dart';
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testCategories = [
    const CategoryEntity(
      id: 'c1',
      nameKey: 'An uong',
      iconCode: 0,
      groupId: 'g1',
    ),
  ];
  String label(CategoryEntity c) => c.nameKey;

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
      expect(items.isNotEmpty, isTrue);
      expect(items.any((it) => it.price >= 30000), isTrue);
    });

    test('should build a concise summary note', () {
      final items = extractItemsFromText(ocrText);
      final note = summarizeBillItems(items);
      expect(note, isNotEmpty);
      expect(note, contains("k)")); // Expecting format like "Item (30k)"
    });

    test('local parse of OCR text without a labeled note field leaves the '
        'note null rather than guessing noise from mis-parsed line items', () {
      final result = parseQuickEntryTextLocally(
        text: ocrText,
        categories: testCategories,
        categoryLabels: label,
      );
      expect(result.note, isNull);
      expect(result.categoryId, isNull);
    });

    test('local parse reads the transfer message from a labeled bank-transfer '
        'screenshot instead of the raw OCR blob', () {
      const bankTransferText = '''
Chuyen tien thanh cong
So tien
500.000d
Noi dung chuyen khoan
An trua nhom du an
Thoi gian
17/11/2026 12:30
''';
      final result = parseQuickEntryTextLocally(
        text: bankTransferText,
        categories: testCategories,
        categoryLabels: label,
      );
      expect(result.note, 'An trua nhom du an');
      expect(result.categoryId, isNull);
    });

    test('local parse reads the e-wallet suggested category from a labeled '
        '"Danh mục" field', () {
      const momoText = '''
Giao dich thanh cong
So tien
100.000d
Danh muc
An uong & Nha hang
Loi nhan
Tra tien com trua
Thoi gian
17/11/2026 12:00
''';
      final result = parseQuickEntryTextLocally(
        text: momoText,
        categories: testCategories,
        categoryLabels: label,
      );
      expect(result.categoryId, 'c1');
      expect(result.note, 'Tra tien com trua');
    });
  });
}
