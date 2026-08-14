import 'dart:convert';

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
@lazySingleton
class ParseQuickEntryUseCase {
  ParseQuickEntryUseCase(this._getCategories);

  final GetCategoriesUseCase _getCategories;

  Future<List<CategoryEntity>> _loadExpenseCategories() async {
    final result = await _getCategories.call();
    return result
            .tryGetSuccess()
            ?.where((c) => c.isEnabled && c.type == CategoryType.expense)
            .toList() ??
        const <CategoryEntity>[];
  }

  Future<QuickEntryParseResult> parseLocally(String text) async {
    final categories = await _loadExpenseCategories();
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
  }) async {
    if (localResult.isComplete) return localResult;

    final categories = await _loadExpenseCategories();
    if (categories.isEmpty) return null;

    final categoryOptions = categories
        .map((c) => '${c.id}: ${el.tr(c.nameKey)}')
        .join(', ');
    final prompt =
        'You extract a Vietnamese personal-expense amount in VND and a '
        'category id from a short free-text or dictated quick-entry string. '
        'Text: "$text". '
        'Available categories (id: label): $categoryOptions. '
        'Reply with ONLY compact JSON, no markdown fences, no explanation: '
        '{"amount": <integer VND or null>, "categoryId": <one of the ids '
        'above as a string, or null>}.';

    final response = await CcGeminiHelper.generateText(prompt: prompt);
    if (response == null) return null;

    final validIds = categories.map((c) => c.id).toSet();
    final cloudResult = _parseJsonResponse(response, validIds: validIds);
    if (cloudResult == null) return null;

    final merged = QuickEntryParseResult(
      amount: localResult.amount ?? cloudResult.amount,
      categoryId: localResult.categoryId ?? cloudResult.categoryId,
    );
    return merged.isEmpty ? null : merged;
  }

  QuickEntryParseResult? _parseJsonResponse(
    String raw, {
    required Set<String> validIds,
  }) {
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) return null;

      final amountValue = decoded['amount'];
      final amount = amountValue is num ? amountValue.round() : null;

      final categoryIdValue = decoded['categoryId'];
      final categoryId = categoryIdValue is String &&
              validIds.contains(categoryIdValue)
          ? categoryIdValue
          : null;

      return QuickEntryParseResult(amount: amount, categoryId: categoryId);
    } catch (_) {
      return null;
    }
  }
}
