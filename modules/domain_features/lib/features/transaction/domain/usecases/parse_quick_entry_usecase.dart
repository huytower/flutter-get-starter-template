import 'dart:convert';
import 'dart:typed_data';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';

/// Phase 3.6 "NLP Simple" quick entry: local-first parsing of free text like
/// "50k cafe" (typed or dictated) into an amount + category, with a cloud
/// Gemini fallback for whatever the local parse couldn't determine. Kept
/// UI-agnostic on purpose — the LV3 gate, consent prompt, and daily-cap
/// check all need a `BuildContext`/user-facing dialog, so those live in
/// `ExpenseFormController`, which calls [parseLocally] first (always safe)
/// and only calls [parseWithCloud] after that gating passes.
///
/// Phase 3.7 receipt-photo entry reuses [parseLocally] as-is (on-device OCR
/// text is just another free-text string) and adds [parseImageWithCloud] as
/// a second cloud escalation path that sends the image itself instead of
/// text.
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

  /// Sends [text] to Gemini to fill in whatever [localResult] is missing.
  /// Local fields always win over the cloud response when both are present
  /// — the local parse is deterministic and free, so there's no reason to
  /// let a cloud answer override it. Returns null on any failure (Gemini
  /// not enabled for this Firebase project yet, network error, unparsable
  /// response) so the caller can surface "couldn't understand" gracefully.
  Future<QuickEntryParseResult?> parseWithCloud({
    required String text,
    required QuickEntryParseResult localResult,
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    if (localResult.isComplete) return localResult;

    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final prompt =
        'You extract a Vietnamese ${_amountKindPhrase(categoryType)} '
        'amount in VND, a category id, a transaction date (only if one is '
        'actually stated, e.g. "hôm qua"/"yesterday"), and a short note '
        '(merchant/item) from a short free-text or dictated quick-entry '
        'string. '
        'Text: "$text". '
        '${_todayReferenceSentence()} '
        '${_buildCategoryOptionsPrompt(categories)}';

    final response = await CcGeminiHelper.generateText(
      prompt: prompt,
      responseSchema: _buildResponseSchema(categories),
    );
    if (response == null) return null;

    return _mergeCloudResponse(
      response,
      categories: categories,
      localResult: localResult,
    );
  }

  /// Same contract as [parseWithCloud], but for a Phase 3.7 receipt photo —
  /// sends the image itself to Gemini (multimodal) rather than pre-extracted
  /// OCR text, since small/faded receipt print often garbles the on-device
  /// OCR pass badly enough that the amount/category are unrecoverable from
  /// text alone.
  Future<QuickEntryParseResult?> parseImageWithCloud({
    required Uint8List imageBytes,
    required String mimeType,
    required QuickEntryParseResult localResult,
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    if (localResult.isComplete) return localResult;

    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final prompt =
        'This image is a Vietnamese ${_receiptKindPhrase(categoryType)}. '
        'Extract the total amount in VND, the best-matching category id, '
        'the transaction date if one is shown, and a short note '
        '(payee/merchant name or item). '
        '${_todayReferenceSentence()} '
        '${_buildCategoryOptionsPrompt(categories)}';

    final response = await CcGeminiHelper.generateFromImage(
      imageBytes: imageBytes,
      mimeType: mimeType,
      prompt: prompt,
      responseSchema: _buildResponseSchema(categories),
    );
    if (response == null) return null;

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

  /// Structured-output schema forcing Gemini to reply with strict JSON
  /// shaped exactly like [QuickEntryParseResult] — every field is required
  /// to be *present* but individually `nullable`, so a field Gemini can't
  /// determine comes back as an explicit JSON `null` rather than being
  /// omitted or the whole reply degrading into prose/markdown. `categoryId`
  /// is constrained to an enum of just the ids offered in the prompt, so
  /// the model is structurally unable to hallucinate an id that doesn't
  /// exist — the client-side `validIds.contains` check in
  /// [_parseJsonResponse] becomes a defense-in-depth backstop rather than
  /// the only line of defense.
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

  /// Validates and merges a raw Gemini JSON response against [localResult] —
  /// local fields always win over the cloud response when both are present,
  /// since the local parse is deterministic and free.
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
      date: localResult.date ?? cloudResult.date,
      note: localResult.note ?? cloudResult.note,
    );
    return merged.isEmpty ? null : merged;
  }

  /// Parses Gemini's JSON reply, validating each field independently — a
  /// bad/missing value in one field (wrong type, an unknown categoryId, an
  /// unparsable or nonsensical date) just drops that field to null rather
  /// than discarding the whole response, so the caller can still surface
  /// whatever *did* come back cleanly and let the user fill the rest in by
  /// hand. Only a fully malformed (non-JSON, non-object) reply returns null
  /// outright, since there's nothing usable to salvage from that.
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
