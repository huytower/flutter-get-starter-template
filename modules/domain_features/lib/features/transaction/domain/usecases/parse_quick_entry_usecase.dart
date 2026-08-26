import 'dart:convert';
import 'dart:typed_data';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';

import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';

/// Parses quick-entry text/voice/photo into an amount + category (+ date/
/// note when available). [parseLocally] (free, offline) always runs first
/// and drives the as-you-type suggestion; [parseWithCloud]/
/// [parseImageWithCloud] are always additionally called on explicit submit
/// — local fields still win in the merge, but Gemini often resolves
/// category/date/note better than the local regex/fuzzy-match even when
/// local already got amount+category. Kept UI-agnostic: the LV3 gate,
/// consent prompt, and daily-cap check need a `BuildContext` and live in
/// `QuickEntryMixin` instead.
@lazySingleton
class ParseQuickEntryUseCase {
  ParseQuickEntryUseCase(this._getCategories);

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

  Future<QuickEntryParseResult> parseLocally(
    String text, {
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    final categories = await _loadCategories(categoryType, groupIds);
    return parseQuickEntryTextLocally(
      text: text,
      categories: categories,
      categoryLabels: (c) => el.tr(c.nameKey),
    );
  }

  /// Sends [text] to Gemini unconditionally; [localResult] fields still win
  /// in the merge. Returns null on any failure so the caller can surface a
  /// generic "couldn't understand" message.
  Future<QuickEntryParseResult?> parseWithCloud({
    required String text,
    required QuickEntryParseResult localResult,
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final prompt =
        'You extract a Vietnamese ${_amountKindPhrase(categoryType)} '
        'amount in VND, a category id, a transaction date, and a short note '
        '(merchant/item) from a short free-text or dictated quick-entry '
        'string. '
        'Text: "$text". '
        '${_todayReferenceSentence()} '
        'IMPORTANT: If the text contains relative dates like "hôm qua" (yesterday), '
        '"hôm kia" (the day before yesterday), or specific dates, resolve them '
        'relative to the provided today\'s date. '
        '${_buildCategoryOptionsPrompt(categories)}';

    '[AI_PARSING] ☁️ Gemini Text Prompt: \n$prompt'.Log(
      'ParseQuickEntryUseCase',
    );

    final response = await CcGeminiHelper.generateText(
      prompt: prompt,
      responseSchema: _buildResponseSchema(categories),
    );

    if (response == null) {
      '[AI_PARSING] ❌ Gemini returned null response'.Log(
        'ParseQuickEntryUseCase',
      );
      return null;
    }
    '[AI_PARSING] 📥 Gemini Text Response: $response'.Log(
      'ParseQuickEntryUseCase',
    );

    return _mergeCloudResponse(
      response,
      categories: categories,
      localResult: localResult,
    );
  }

  /// Same contract as [parseWithCloud], but sends the receipt image itself
  /// (multimodal) rather than pre-extracted OCR text — small/faded print
  /// often garbles OCR badly enough to lose the amount/category.
  Future<QuickEntryParseResult?> parseImageWithCloud({
    required Uint8List imageBytes,
    required String mimeType,
    required QuickEntryParseResult localResult,
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final prompt =
        'This image is a Vietnamese ${_receiptKindPhrase(categoryType)}. '
        'Extract the total amount in VND, the best-matching category id, '
        'the transaction date if one is shown, and a short note '
        '(payee/merchant name or item). '
        '${_todayReferenceSentence()} '
        '${_buildCategoryOptionsPrompt(categories)}';

    '[AI_PARSING] 🖼️ Gemini Image Prompt: \n$prompt'.Log(
      'ParseQuickEntryUseCase',
    );

    final response = await CcGeminiHelper.generateFromImage(
      imageBytes: imageBytes,
      mimeType: mimeType,
      prompt: prompt,
      responseSchema: _buildResponseSchema(categories),
    );

    if (response == null) {
      '[AI_PARSING] ❌ Gemini image response is null'.Log(
        'ParseQuickEntryUseCase',
      );
      return null;
    }
    '[AI_PARSING] 📥 Gemini Image Response: $response'.Log(
      'ParseQuickEntryUseCase',
    );

    return _mergeCloudResponse(
      response,
      categories: categories,
      localResult: localResult,
    );
  }

  /// Describes what kind of amount is being extracted, for the free-text
  /// quick-entry prompt — e.g. "personal expense" vs. "personal income".
  String _amountKindPhrase(String categoryType) => switch (categoryType) {
    CategoryType.income => 'personal income',
    CategoryType.investment => 'investment contribution or return',
    CategoryType.debtLoan => 'loan/debt',
    _ => 'personal expense',
  };

  /// Describes what kind of image is being scanned, for the receipt-photo
  /// prompt.
  String _receiptKindPhrase(String categoryType) => switch (categoryType) {
    CategoryType.income =>
      'income receipt, salary slip, or money-received screenshot',
    CategoryType.investment =>
      'investment transaction confirmation or screenshot',
    CategoryType.debtLoan => 'loan/debt agreement or bank transfer screenshot',
    _ => 'personal-expense receipt or payment screenshot',
  };

  String _buildCategoryOptionsPrompt(List<CategoryEntity> categories) {
    final categoryOptions = categories
        .map((c) => '${c.id}: ${el.tr(c.nameKey)}')
        .join(', ');
    return 'Available categories (id: label): $categoryOptions.';
  }

  /// Gives the model a "now" reference so it can resolve relative dates
  /// (e.g. "hôm qua") — without this it has no way to know the actual
  /// current date.
  String _todayReferenceSentence() {
    final now = DateTime.now();
    final iso =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return "Today's date is $iso.";
  }

  /// Forces strict JSON matching [QuickEntryParseResult], every field
  /// nullable so an unresolved field comes back as explicit `null` instead
  /// of prose. `categoryId` is enum-constrained to the offered ids, so
  /// [_parseJsonResponse]'s `validIds.contains` check is defense-in-depth,
  /// not the only guard against a hallucinated id.
  Schema _buildResponseSchema(List<CategoryEntity> categories) {
    return Schema.object(
      properties: {
        'amount': Schema.integer(
          description:
              'Total transaction amount in VND, or null if not '
              'determinable.',
          nullable: true,
          minimum: 1,
        ),
        'categoryId': Schema.enumString(
          enumValues: categories.map((c) => c.id).toList(),
          description:
              'Best-matching category id from the offered list, '
              'or null if none fits.',
          nullable: true,
        ),
        'date': Schema.string(
          description:
              'Transaction date as YYYY-MM-DD, or null if not '
              'stated/shown.',
          nullable: true,
        ),
        'note': Schema.string(
          description:
              'Short note describing the purchase (merchant or '
              'item), in Vietnamese, or null.',
          nullable: true,
        ),
      },
    );
  }

  /// Merges a raw Gemini JSON response with [localResult] — local fields
  /// always win when both are present.
  QuickEntryParseResult? _mergeCloudResponse(
    String response, {
    required List<CategoryEntity> categories,
    required QuickEntryParseResult localResult,
  }) {
    final validIds = categories.map((c) => c.id).toSet();
    final cloudResult = _parseJsonResponse(response, validIds: validIds);
    if (cloudResult == null) return null;

    final merged = QuickEntryParseResult(
      amount: localResult.amount ?? cloudResult.amount,
      categoryId: localResult.categoryId ?? cloudResult.categoryId,
      date: cloudResult.date ?? localResult.date,
      note: localResult.note ?? cloudResult.note,
    );
    return merged.isEmpty ? null : merged;
  }

  /// Validates each field independently — a bad value in one field just
  /// drops that field to null rather than discarding the whole response.
  /// Only a non-JSON/non-object reply returns null outright.
  QuickEntryParseResult? _parseJsonResponse(
    String raw, {
    required Set<String> validIds,
  }) {
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) return null;

      final amountValue = decoded['amount'];
      final amount = amountValue is num && amountValue > 0
          ? amountValue.round()
          : null;

      final categoryIdValue = decoded['categoryId'];
      final categoryId =
          categoryIdValue is String && validIds.contains(categoryIdValue)
          ? categoryIdValue
          : null;

      final dateValue = decoded['date'];
      DateTime? date;
      if (dateValue is String) {
        final parsed = DateTime.tryParse(dateValue);
        // A receipt/quick-entry date can't be in the future — treat that as
        // a bad read rather than trust it.
        if (parsed != null && !parsed.isAfter(DateTime.now())) {
          date = parsed;
        }
      }

      final noteValue = decoded['note'];
      final note = noteValue is String && noteValue.trim().isNotEmpty
          ? noteValue.trim()
          : null;

      return QuickEntryParseResult(
        amount: amount,
        categoryId: categoryId,
        date: date,
        note: note,
      );
    } catch (_) {
      return null;
    }
  }
}
