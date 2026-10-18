import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';

import '../../../../core/constant/currency_catalog.dart';
import '../../../../core/constant/currency_constants.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

@lazySingleton
class ParseQuickEntryUseCase {
  ParseQuickEntryUseCase(this._getCategories);

  final GetCategoriesUseCase _getCategories;
  WalletRepository get _walletRepository => getIt<WalletRepository>();

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
    final walletsResult = await _walletRepository.getWallets();
    final wallets = walletsResult.tryGetSuccess();

    return parseQuickEntryTextLocally(
      text: text,
      categories: categories,
      categoryLabels: (c) => el.tr(c.nameKey),
      wallets: wallets,
    );
  }

  Future<QuickEntryParseResult?> parseWithCloud({
    required String text,
    required QuickEntryParseResult localResult,
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    if (!await getIt<AiFallbackPreferenceDataSource>().isGeminiEnabled()) {
      return null;
    }
    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final walletsResult = await _walletRepository.getWallets();
    final wallets = walletsResult.tryGetSuccess() ?? [];
    final currency = _primaryCurrency();

    final prompt =
        'You extract a ${_amountKindPhrase(categoryType)} '
        'amount, a category id, a wallet id, a transaction date, and a short note '
        '(merchant/item) from a short free-text or dictated quick-entry '
        'string in any language (Vietnamese is the most common). '
        'Text: "$text". '
        '${_currencyPromptSentence(currency)} '
        '${_todayReferenceSentence()} '
        'IMPORTANT: If the text contains relative dates like "hôm qua" (yesterday), '
        '"hôm kia" (the day before yesterday), or specific dates, resolve them '
        'relative to the provided today\'s date. '
        '${_buildCategoryOptionsPrompt(categories)} '
        '${_buildWalletOptionsPrompt(wallets)}';

    '[AI_PARSING] [GEMINI] ☁️ Gemini Text Prompt: \n$prompt'.Log(
      'ParseQuickEntryUseCase',
    );

    final response = await CcGeminiHelper.generateText(
      prompt: prompt,
      responseSchema: _buildResponseSchema(categories, wallets, currency),
    );

    if (response == null) {
      '[AI_PARSING] [GEMINI] ❌ Gemini returned null response'.Log(
        'ParseQuickEntryUseCase',
      );
      return null;
    }
    '[AI_PARSING] [GEMINI] 📥 Gemini Text Response: $response'.Log(
      'ParseQuickEntryUseCase',
    );

    return _mergeCloudResponse(
      response,
      categories: categories,
      wallets: wallets,
      localResult: localResult,
      currency: currency,
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
    if (!await getIt<AiFallbackPreferenceDataSource>().isGeminiEnabled()) {
      return null;
    }
    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final walletsResult = await _walletRepository.getWallets();
    final wallets = walletsResult.tryGetSuccess() ?? [];
    final currency = _primaryCurrency();

    final prompt =
        'This image is a ${_receiptKindPhrase(categoryType)}. '
        'Extract the total amount, the best-matching category id, '
        'the wallet id, '
        'the transaction date if one is shown, and a short note. '
        'If this is a receipt, the note should be the merchant name. '
        'If there are line items, list them concisely in the note like: "Item1, Item2...". '
        '${_currencyPromptSentence(currency)} '
        '${_todayReferenceSentence()} '
        '${_buildCategoryOptionsPrompt(categories)} '
        '${_buildWalletOptionsPrompt(wallets)}';

    '[AI_PARSING] [GEMINI] 🖼️ Gemini Image Prompt: \n$prompt'.Log(
      'ParseQuickEntryUseCase',
    );

    final response = await CcGeminiHelper.generateFromImage(
      imageBytes: imageBytes,
      mimeType: mimeType,
      prompt: prompt,
      responseSchema: _buildResponseSchema(categories, wallets, currency),
    );

    if (response == null) {
      '[AI_PARSING] [GEMINI] ❌ Gemini image response is null'.Log(
        'ParseQuickEntryUseCase',
      );
      return null;
    }
    '[AI_PARSING] [GEMINI] 📥 Gemini Image Response: $response'.Log(
      'ParseQuickEntryUseCase',
    );

    return _mergeCloudResponse(
      response,
      categories: categories,
      wallets: wallets,
      localResult: localResult,
      currency: currency,
    );
  }

  String _amountKindPhrase(String categoryType) => switch (categoryType) {
    CategoryType.income => 'personal income',
    CategoryType.investment => 'investment contribution or return',
    CategoryType.liability => 'loan/debt',
    _ => 'personal expense',
  };

  String _receiptKindPhrase(String categoryType) => switch (categoryType) {
    CategoryType.income =>
      'income receipt, salary slip, or money-received screenshot',
    CategoryType.investment =>
      'investment transaction confirmation or screenshot',
    CategoryType.liability => 'loan/debt agreement or bank transfer screenshot',
    _ => 'personal-expense receipt or payment screenshot',
  };

  String _buildCategoryOptionsPrompt(List<CategoryEntity> categories) {
    final categoryOptions = categories
        .map((c) => '${c.id}: ${el.tr(c.nameKey)}')
        .join(', ');
    return 'Available categories (id: label): $categoryOptions.';
  }

  String _buildWalletOptionsPrompt(List<WalletEntity> wallets) {
    if (wallets.isEmpty) return '';
    final walletOptions = wallets.map((w) => '${w.id}: ${w.name}').join(', ');
    return 'Available wallets (id: name): $walletOptions.';
  }

  String _todayReferenceSentence() {
    final now = DateTime.now();
    final iso =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return "Today's date is $iso.";
  }

  CurrencyDefinition _primaryCurrency() =>
      CurrencyCatalog.getDefinition(CurrencyConstants.currentPrimaryCurrency);

  String _currencyPromptSentence(CurrencyDefinition currency) =>
      "The user's primary currency is ${currency.code} (${currency.symbol}). "
      'Return "amount" as the number in whole ${currency.code} units, '
      'keeping any decimals (e.g. 12.5 for 12 and a half), never converted to '
      'cents or another currency. Amounts with no explicit currency are in '
      '${currency.code}, including when only an ambiguous symbol such as \$ '
      'or ¥ is shown. Return "currencyCode" only when a different currency is '
      'explicitly written or shown. Expand shorthand such as 50k, 50 nghìn, '
      '1,5 triệu / 1.5tr (1,500,000), 万 (10,000), 만 / 천 (10,000 / 1,000). '
      'A "." or "," followed by exactly three digits is a thousands '
      'separator, otherwise it is a decimal separator.';

  Schema _buildResponseSchema(
    List<CategoryEntity> categories,
    List<WalletEntity> wallets,
    CurrencyDefinition currency,
  ) {
    return Schema.object(
      properties: {
        'amount': Schema.number(
          description:
              'Total transaction amount in whole ${currency.code} units '
              '(decimals allowed), or null if not determinable.',
          nullable: true,
          minimum: 0.01,
        ),
        'currencyCode': Schema.enumString(
          enumValues: CurrencyConstants.supportedCurrencyCodes,
          description:
              'ISO code of the currency explicitly written or shown in the '
              'input, or null if none is stated.',
          nullable: true,
        ),
        'categoryId': Schema.enumString(
          enumValues: categories.map((c) => c.id).toList(),
          description:
              'Best-matching category id from the offered list, '
              'or null if none fits.',
          nullable: true,
        ),
        'walletId': Schema.enumString(
          enumValues: wallets.map((w) => w.id).toList(),
          description:
              'Best-matching wallet id from the offered list, '
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

  QuickEntryParseResult? _mergeCloudResponse(
    String response, {
    required List<CategoryEntity> categories,
    required List<WalletEntity> wallets,
    required QuickEntryParseResult localResult,
    required CurrencyDefinition currency,
  }) {
    final validCatIds = categories.map((c) => c.id).toSet();
    final validWalletIds = wallets.map((w) => w.id).toSet();
    final parsed = _parseJsonResponse(
      response,
      validCatIds: validCatIds,
      validWalletIds: validWalletIds,
      currency: currency,
    );
    if (parsed == null) return null;
    final cloudResult = parsed.result;

    final merged = QuickEntryParseResult(
      amount: parsed.foreignCurrency
          ? null
          : cloudResult.amount ?? localResult.amount,
      categoryId: cloudResult.categoryId ?? localResult.categoryId,
      walletId: cloudResult.walletId ?? localResult.walletId,
      date: cloudResult.date ?? localResult.date,
      note: cloudResult.note ?? localResult.note,
    );
    return merged.isEmpty ? null : merged;
  }

  ({QuickEntryParseResult result, bool foreignCurrency})? _parseJsonResponse(
    String raw, {
    required Set<String> validCatIds,
    required Set<String> validWalletIds,
    required CurrencyDefinition currency,
  }) {
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) return null;

      final amountValue = decoded['amount'];
      final statedCurrency = decoded['currencyCode'];
      final isForeignCurrency =
          statedCurrency is String &&
          statedCurrency.isNotEmpty &&
          statedCurrency.toUpperCase() != currency.code;
      final amount = !isForeignCurrency && amountValue is num && amountValue > 0
          ? amountValue.round()
          : null;

      final categoryIdValue = decoded['categoryId'];
      final categoryId =
          categoryIdValue is String && validCatIds.contains(categoryIdValue)
          ? categoryIdValue
          : null;

      final walletIdValue = decoded['walletId'];
      final walletId =
          walletIdValue is String && validWalletIds.contains(walletIdValue)
          ? walletIdValue
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

      return (
        result: QuickEntryParseResult(
          amount: amount,
          categoryId: categoryId,
          walletId: walletId,
          date: date,
          note: note,
        ),
        foreignCurrency: isForeignCurrency,
      );
    } catch (_) {
      return null;
    }
  }
}
