import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:string_similarity/string_similarity.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../../core/helper/merchant_match_helper.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../entities/bill_parse_result.dart';

@lazySingleton
class ParseBillImageUseCase {
  ParseBillImageUseCase(this._getCategories);

  final GetCategoriesUseCase _getCategories;

  Future<List<CategoryEntity>> _loadCategories(
    String categoryType,
    List<String>? groupIds,
  ) async {
    final result = await _getCategories.call();
    return result
            .tryGetSuccess()
            ?.where(
              (c) =>
                  c.isEnabled &&
                  c.type == categoryType &&
                  (groupIds == null || groupIds.contains(c.groupId)),
            )
            .toList() ??
        const <CategoryEntity>[];
  }

  Future<String> _runOcr(String imagePath) async {
    '[AI_PARSING] 🔍 Running on-device OCR on bill image'.Log(
      'ParseBillImageUseCase',
    );
    final text = await CcReceiptScanHelper.recognizeText(imagePath);
    '[AI_PARSING] 📝 OCR completed | textLength=${text.length}'.Log(
      'ParseBillImageUseCase',
    );
    return text;
  }

  /// Extracts invoice/serial numbers from Vietnamese receipt OCR text.
  /// Matches patterns like "so: 111800005", "số 111800005", "so111800005".
  static String? _extractInvoiceNumber(String text) {
    final normalized = stripVietnameseDiacritics(text.toLowerCase());
    final regex = RegExp(
      r'(?:s[oô]|so)\s*:?\s*([0-9]{4,20})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(normalized);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }

  static String _stripInvoiceNumbers(String text) {
    final normalized = stripVietnameseDiacritics(text);
    return normalized.replaceAllMapped(
      invoiceNumberPattern,
      (match) {
        final stripped = match.group(0)!;
        '[AI_PARSING] 🚫 Serial/invoice number stripped | "$stripped"'.Log(
          'ParseBillImageUseCase',
        );
        return ' ';
      },
    );
  }

  Future<BillParseResult?> parse({
    required Uint8List imageBytes,
    required String mimeType,
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp('bill_parse_');
    final tempPath = p.join(tempDir.path, 'bill_input${p.extension(mimeType.split('/').last)}');
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(imageBytes);

    try {
      final categories = await _loadCategories(categoryType, groupIds);
      final ocrText = await _runOcr(tempPath);

      final invoiceNumber = _extractInvoiceNumber(ocrText);
      if (invoiceNumber != null) {
        '[AI_PARSING] 🧾 Invoice/serial number found | invoiceNumber=$invoiceNumber'.Log(
          'ParseBillImageUseCase',
        );
      }

      final cleanedOcrText = _stripInvoiceNumbers(ocrText);

      '[AI_PARSING] 📸 Bill image OCR preview | text="$cleanedOcrText"'.Log(
        'ParseBillImageUseCase',
      );

      final prompt =
          'You are a Vietnamese receipt/bill parser. Extract structured data from the following OCR text of a bill or receipt. '
          'OCR text: "$cleanedOcrText". '
          '${_buildCategoryOptionsPrompt(categories)} '
          'The receipt may have a table with columns: item name (mat hang), quantity (sl), unit price (gia), line total (thanh tien / t tien). '
          'Line item amounts should come from the "thanh tien" or "t tien" column, NOT from "tong" (grand total), "tien hang" (subtotal), or "giam" (discount). '
          'Ignore phone numbers, serial/invoice numbers (so:/số:), dates, times, cashier names, and any text outside the item table. '
          'Return ONLY valid JSON matching the provided schema. '
          'If you cannot confidently identify line items, return an empty items array. '
          'Amounts must be integers in VND (no currency symbols). Prices may use space as thousand separator (e.g. "35 000").';

      '[AI_PARSING] 🖼️ Gemini Bill Prompt: \n$prompt'.Log(
        'ParseBillImageUseCase',
      );

      final response = await CcGeminiHelper.generateFromImage(
        imageBytes: imageBytes,
        mimeType: mimeType,
        prompt: prompt,
        responseSchema: _buildResponseSchema(categories),
      );

      if (response == null) {
        '[AI_PARSING] ❌ Gemini bill image response is null'.Log(
          'ParseBillImageUseCase',
        );
        return null;
      }

      '[AI_PARSING] 📥 Gemini Bill Response: $response'.Log(
        'ParseBillImageUseCase',
      );

      final geminiResult = _parseJsonResponse(response, categories, invoiceNumber);
      if (geminiResult != null && geminiResult.items.isNotEmpty) {
        return geminiResult;
      }

      '[AI_PARSING] 🔄 Gemini returned no items, falling back to phrase-based extraction'
          .Log('ParseBillImageUseCase');
      final phraseItems = _extractItemsFromPhrases(cleanedOcrText);
      if (phraseItems.isNotEmpty) {
        return BillParseResult(
          vendor: geminiResult?.vendor,
          date: geminiResult?.date,
          totalAmount: geminiResult?.totalAmount,
          taxAmount: geminiResult?.taxAmount,
          discountAmount: geminiResult?.discountAmount,
          items: phraseItems,
          categoryHint: geminiResult?.categoryHint ?? invoiceNumber,
          invoiceNumber: invoiceNumber,
        );
      }

      return geminiResult;
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  String _buildCategoryOptionsPrompt(List<CategoryEntity> categories) {
    final categoryOptions = categories
        .map((c) => '${c.id}: ${el.tr(c.nameKey)}')
        .join(', ');
    return 'Available categories (id: label): $categoryOptions. ';
  }

  Schema _buildResponseSchema(List<CategoryEntity> categories) {
    return Schema.object(
      properties: {
        'vendor': Schema.string(
          description: 'Merchant or vendor name, or null if not found.',
          nullable: true,
        ),
        'date': Schema.string(
          description: 'Transaction date as YYYY-MM-DD, or null.',
          nullable: true,
        ),
        'totalAmount': Schema.integer(
          description: 'Total bill amount in VND, or null.',
          nullable: true,
          minimum: 0,
        ),
        'taxAmount': Schema.integer(
          description: 'Tax/VAT amount in VND, or null.',
          nullable: true,
          minimum: 0,
        ),
        'discountAmount': Schema.integer(
          description: 'Discount amount in VND, or null.',
          nullable: true,
          minimum: 0,
        ),
        'categoryHint': Schema.enumString(
          enumValues: categories.map((c) => c.id).toList(),
          description: 'Best-matching category id, or null.',
          nullable: true,
        ),
        'items': Schema.array(
          items: Schema.object(
            properties: {
              'name': Schema.string(description: 'Item name.'),
              'quantity': Schema.integer(
                description: 'Quantity, or null.',
                nullable: true,
                minimum: 1,
              ),
              'unitPrice': Schema.integer(
                description: 'Unit price in VND, or null.',
                nullable: true,
                minimum: 0,
              ),
              'totalPrice': Schema.integer(
                description: 'Line total in VND, or null.',
                nullable: true,
                minimum: 0,
              ),
            },
          ),
          description: 'Line items, or empty array if none detected.',
          nullable: true,
        ),
      },
    );
  }

  BillParseResult? _parseJsonResponse(
    String raw,
    List<CategoryEntity> categories,
    String? invoiceNumber,
  ) {
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) return null;

      final validIds = categories.map((c) => c.id).toSet();

      String? vendor;
      if (decoded['vendor'] is String) vendor = decoded['vendor'];

      DateTime? date;
      if (decoded['date'] is String) {
        final parsed = DateTime.tryParse(decoded['date']);
        if (parsed != null && !parsed.isAfter(DateTime.now())) date = parsed;
      }

      int? totalAmount;
      if (decoded['totalAmount'] is num && decoded['totalAmount'] > 0) {
        totalAmount = (decoded['totalAmount'] as num).round();
      }

      int? taxAmount;
      if (decoded['taxAmount'] is num && decoded['taxAmount'] >= 0) {
        taxAmount = (decoded['taxAmount'] as num).round();
      }

      int? discountAmount;
      if (decoded['discountAmount'] is num && decoded['discountAmount'] >= 0) {
        discountAmount = (decoded['discountAmount'] as num).round();
      }

      String? categoryHint;
      if (decoded['categoryHint'] is String && validIds.contains(decoded['categoryHint'])) {
        categoryHint = decoded['categoryHint'];
      }

      List<BillItem> items = [];
      if (decoded['items'] is List) {
        for (final item in decoded['items']) {
          if (item is! Map) continue;
          final name = item['name'] is String ? item['name'] : null;
          final quantity = item['quantity'] is num && item['quantity'] > 0
              ? (item['quantity'] as num).round()
              : null;
          final unitPrice = item['unitPrice'] is num && item['unitPrice'] >= 0
              ? (item['unitPrice'] as num).round()
              : null;
          final totalPrice = item['totalPrice'] is num && item['totalPrice'] >= 0
              ? (item['totalPrice'] as num).round()
              : null;
          items.add(
            BillItem(
              name: name,
              quantity: quantity,
              unitPrice: unitPrice,
              totalPrice: totalPrice,
            ),
          );
        }
      }

      return BillParseResult(
        vendor: vendor,
        date: date,
        totalAmount: totalAmount,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        items: items,
        categoryHint: categoryHint,
        invoiceNumber: invoiceNumber,
      );
    } catch (_) {
      return null;
    }
  }

  static final RegExp _phraseAmountPattern = RegExp(
    r'(\d{1,3}(?:[., ]\d{3})+|\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu|ty|b|d|vnd|dong)?',
  );

  static const _stopWords = {
    'tien hang',
    'giam',
    'tong',
    't tien',
    'thanh tien',
    'ban',
    'gio ra',
    'gio vao',
    'thu ngan',
    'mat hang',
    'sl',
    'gia',
    'cam on',
    'in luc',
    'so:',
    'so ',
    'so',
  };

  List<BillItem> _extractItemsFromPhrases(String ocrText) {
    final cleaned = stripInvoiceNumbers(stripPhoneNumbers(ocrText));
    final lines = cleaned
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Collect all valid amounts with their line index.
    final amountEntries = <({int lineIndex, int value})>[];
    for (int i = 0; i < lines.length; i++) {
      final matches = _phraseAmountPattern.allMatches(lines[i]).toList();
      for (final match in matches) {
        final numeric = match.group(1)!.replaceAll(RegExp('[., ]'), '');
        final value = int.tryParse(numeric);
        if (value != null && value >= 1000 && value <= 100000000) {
          amountEntries.add((lineIndex: i, value: value));
        }
      }
    }

    // Deduplicate amounts on the same line — keep the first occurrence.
    final seenLines = <int>{};
    final uniqueAmounts = <({int lineIndex, int value})>[];
    for (final entry in amountEntries) {
      if (seenLines.contains(entry.lineIndex)) continue;
      seenLines.add(entry.lineIndex);
      uniqueAmounts.add(entry);
    }

    final items = <BillItem>[];
    final usedNames = <String>[];

    for (final entry in uniqueAmounts) {
      // Look backwards up to 5 lines for the item name.
      final nameParts = <String>[];
      for (int i = entry.lineIndex - 1; i >= 0 && i >= entry.lineIndex - 5; i--) {
        final line = lines[i];
        final lower = line.toLowerCase();
        if (_stopWords.any(lower.contains)) break;
        if (_phraseAmountPattern.hasMatch(line)) break;
        if (line.length < 2 || line.length > 60) continue;
        nameParts.insert(0, line);
      }

      if (nameParts.isEmpty) continue;
      var name = nameParts.join(' ').trim();
      if (name.length < 2) continue;

      // Skip if this name is too similar to one we already captured.
      if (usedNames.any((existing) => _isSimilarName(existing, name))) {
        continue;
      }

      usedNames.add(name);
      items.add(BillItem(name: name, totalPrice: entry.value));
    }

    '[AI_PARSING] 📝 Phrase extraction found ${items.length} items'.Log(
      'ParseBillImageUseCase',
    );
    return items;
  }

  bool _isSimilarName(String a, String b) {
    final normalizedA = a.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final normalizedB = b.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalizedA == normalizedB) return true;
    if (normalizedA.contains(normalizedB) || normalizedB.contains(normalizedA)) {
      return true;
    }
    final similarity = normalizedA.similarityTo(normalizedB);
    return similarity > 0.7;
  }
}
