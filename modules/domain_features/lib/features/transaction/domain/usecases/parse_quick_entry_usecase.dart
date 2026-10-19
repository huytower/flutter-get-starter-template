import 'dart:convert';
import 'dart:typed_data';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../../../core/constant/currency_catalog.dart';
import '../../../../core/constant/currency_constants.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../../core/exchange_rates/exchange_rate_types.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

typedef ParsedCloudItem = ({
  QuickEntryParseResult result,
  String? foreignCurrencyCode,
  num? foreignAmount,
});

@lazySingleton
class ParseQuickEntryUseCase {
  ParseQuickEntryUseCase(this._getCategories, this._conversionService);

  static final RegExp _iso4217Pattern = RegExp(r'^[A-Z]{3}$');

  static const Map<String, String> _languageNames = {
    'vi': 'Vietnamese',
    'en': 'English',
  };

  final GetCategoriesUseCase _getCategories;
  final CurrencyConversionService _conversionService;
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
    String? languageCode,
  }) async {
    if (!await getIt<AiFallbackPreferenceDataSource>().isGeminiEnabled()) {
      return null;
    }
    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final walletsResult = await _walletRepository.getWallets();
    final wallets = walletsResult.tryGetSuccess() ?? [];
    final currency = _primaryCurrency();
    final language = resolveLanguageName(languageCode);

    final prompt =
        'You extract a ${_amountKindPhrase(categoryType)} '
        'amount, a category id, a wallet id, a transaction date, and a short note '
        '(merchant/item) from a short free-text or dictated quick-entry '
        'string in any language (Vietnamese is the most common). '
        'Text: "$text". '
        '${currencyPromptSentence(currency)} '
        '${noteLanguagePromptSentence(language)} '
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
      responseSchema: buildResponseSchema(
        categories,
        wallets,
        currency,
        language,
      ),
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

    return mergeCloudResponse(
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
    String? languageCode,
  }) async {
    if (!await getIt<AiFallbackPreferenceDataSource>().isGeminiEnabled()) {
      return null;
    }
    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final walletsResult = await _walletRepository.getWallets();
    final wallets = walletsResult.tryGetSuccess() ?? [];
    final currency = _primaryCurrency();
    final language = resolveLanguageName(languageCode);

    final prompt =
        'This image is a ${_receiptKindPhrase(categoryType)}. '
        'Extract the total amount, the best-matching category id, '
        'the wallet id, '
        'the transaction date if one is shown, and a short note. '
        'If this is a receipt, the note should be the merchant name. '
        'If there are line items, list them concisely in the note like: "Item1, Item2...". '
        '${currencyPromptSentence(currency)} '
        '${noteLanguagePromptSentence(language)} '
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
      responseSchema: buildResponseSchema(
        categories,
        wallets,
        currency,
        language,
      ),
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

    return mergeCloudResponse(
      response,
      categories: categories,
      wallets: wallets,
      localResult: localResult,
      currency: currency,
    );
  }

  Future<List<QuickEntryParseResult?>?> parseImagesWithCloud({
    required List<({Uint8List bytes, String mimeType})> images,
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
    String? languageCode,
  }) async {
    if (images.isEmpty) return null;
    if (!await getIt<AiFallbackPreferenceDataSource>().isGeminiEnabled()) {
      return null;
    }
    final categories = await _loadCategories(categoryType, groupIds);
    if (categories.isEmpty) return null;

    final walletsResult = await _walletRepository.getWallets();
    final wallets = liquidWallets(walletsResult.tryGetSuccess() ?? []);
    final currency = _primaryCurrency();
    final language = resolveLanguageName(languageCode);
    final count = images.length;

    final prompt =
        'You are given $count images in order (image 1 to image $count). '
        'Each image is a separate ${_receiptKindPhrase(categoryType)}. '
        'For every image, extract the total amount, the best-matching '
        'category id, the wallet id, the transaction date if one is shown, '
        'and a short note. '
        'Return exactly $count entries in "items", one per image, in the same '
        'order, each with "imageIndex" set to the 1-based position of its '
        'image. If an image is not a readable receipt, return its entry with '
        'a null amount. '
        'If an image is a receipt, the note should be the merchant name. '
        'If there are line items, list them concisely in the note like: "Item1, Item2...". '
        '${currencyPromptSentence(currency)} '
        '${noteLanguagePromptSentence(language)} '
        '${_todayReferenceSentence()} '
        '${_buildCategoryOptionsPrompt(categories)} '
        '${_buildWalletOptionsPrompt(wallets)}';

    '[AI_PARSING] [GEMINI] 🖼️ Gemini Batch Prompt ($count images): \n$prompt'
        .Log('ParseQuickEntryUseCase');

    final response = await CcGeminiHelper.generateFromImages(
      images: images,
      prompt: prompt,
      responseSchema: buildBatchResponseSchema(
        categories,
        wallets,
        currency,
        language,
        count,
      ),
    );

    if (response == null) {
      '[AI_PARSING] [GEMINI] ❌ Gemini batch response is null'.Log(
        'ParseQuickEntryUseCase',
      );
      return null;
    }
    '[AI_PARSING] [GEMINI] 📥 Gemini Batch Response: $response'.Log(
      'ParseQuickEntryUseCase',
    );

    final parsed = parseBatchJsonResponse(
      response,
      imageCount: count,
      validCatIds: categories.map((c) => c.id).toSet(),
      validWalletIds: wallets.map((w) => w.id).toSet(),
      currency: currency,
    );
    if (parsed == null) return null;

    return Future.wait([
      for (final item in parsed) finalizeBatchItem(item, currency),
    ]);
  }

  @visibleForTesting
  List<WalletEntity> liquidWallets(List<WalletEntity> wallets) =>
      wallets.where((w) => w.type != WalletType.investment).toList();

  @visibleForTesting
  Future<QuickEntryParseResult?> finalizeBatchItem(
    ParsedCloudItem? item,
    CurrencyDefinition currency,
  ) async {
    if (item == null) return null;
    final foreignCode = item.foreignCurrencyCode;
    final result = foreignCode == null
        ? item.result
        : item.result.copyWith(
            amount: await _convertForeignAmount(
              item.foreignAmount,
              from: foreignCode,
              to: currency.code,
            ),
          );
    return result.isEmpty ? null : result;
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

  @visibleForTesting
  String resolveLanguageName(String? languageCode) {
    final code = (languageCode ?? CcLocalization.fallbackLocale.languageCode)
        .toLowerCase();
    return _languageNames[code] ?? code;
  }

  @visibleForTesting
  String noteLanguagePromptSentence(String language) =>
      'Write "note" in $language, whatever language the input is in, but '
      'keep merchant, brand and product names as written.';

  @visibleForTesting
  String currencyPromptSentence(CurrencyDefinition currency) =>
      "The user's primary currency is ${currency.code} (${currency.symbol}). "
      'Return "amount" as the number exactly as written, in whole units of '
      'the currency it is written in, keeping any decimals (e.g. 12.5 for 12 '
      'and a half) and never converting it to another currency or to cents. '
      'Amounts with no currency written or shown are in ${currency.code}. '
      'Return "currencyCode" as the ISO 4217 code of '
      'any currency that is written or shown, by symbol, code or name '
      '(\$ is USD, € is EUR, ₩ is KRW, đ is VND, 円 is JPY, 元 is CNY, and ¥ '
      'is ${currency.code} when that is JPY or CNY, otherwise JPY), even if '
      'it is not a currency this app supports. Expand shorthand such as 50k, '
      '50 nghìn, 1,5 triệu / 1.5tr (1,500,000), 千 / 천 (1,000), 万 / 만 '
      '(10,000), 億 / 亿 / 억 (100,000,000). A "." or "," followed by exactly '
      'three digits is a thousands separator, otherwise it is a decimal '
      'separator.';

  @visibleForTesting
  Schema buildResponseSchema(
    List<CategoryEntity> categories,
    List<WalletEntity> wallets,
    CurrencyDefinition currency,
    String language,
  ) {
    return Schema.object(
      properties: _itemProperties(categories, wallets, currency, language),
    );
  }

  @visibleForTesting
  Schema buildBatchResponseSchema(
    List<CategoryEntity> categories,
    List<WalletEntity> wallets,
    CurrencyDefinition currency,
    String language,
    int imageCount,
  ) {
    return Schema.object(
      properties: {
        'items': Schema.array(
          items: Schema.object(
            properties: {
              'imageIndex': Schema.integer(
                description:
                    '1-based position of the image this entry describes.',
                minimum: 1,
                maximum: imageCount,
              ),
              ..._itemProperties(categories, wallets, currency, language),
            },
          ),
          minItems: imageCount,
          maxItems: imageCount,
        ),
      },
    );
  }

  Map<String, Schema> _itemProperties(
    List<CategoryEntity> categories,
    List<WalletEntity> wallets,
    CurrencyDefinition currency,
    String language,
  ) {
    return {
      'amount': Schema.number(
        description:
            'Total transaction amount in whole units of the currency it is '
            'written in (${currency.code} when none is stated), decimals '
            'allowed, never converted, or null if not determinable.',
        nullable: true,
        minimum: 0.01,
      ),
      'currencyCode': Schema.string(
        description:
            'ISO 4217 code of any currency written or shown in the input '
            '(even an unsupported one), or null if none is stated.',
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
            'item), in $language, or null.',
        nullable: true,
      ),
    };
  }

  @visibleForTesting
  Future<QuickEntryParseResult?> mergeCloudResponse(
    String response, {
    required List<CategoryEntity> categories,
    required List<WalletEntity> wallets,
    required QuickEntryParseResult localResult,
    required CurrencyDefinition currency,
  }) async {
    final validCatIds = categories.map((c) => c.id).toSet();
    final validWalletIds = wallets.map((w) => w.id).toSet();
    final parsed = parseJsonResponse(
      response,
      validCatIds: validCatIds,
      validWalletIds: validWalletIds,
      currency: currency,
    );
    if (parsed == null) return null;
    final cloudResult = parsed.result;
    final foreignCode = parsed.foreignCurrencyCode;

    final merged = QuickEntryParseResult(
      amount: foreignCode == null
          ? cloudResult.amount ?? localResult.amount
          : await _convertForeignAmount(
              parsed.foreignAmount,
              from: foreignCode,
              to: currency.code,
            ),
      categoryId: cloudResult.categoryId ?? localResult.categoryId,
      walletId: cloudResult.walletId ?? localResult.walletId,
      date: cloudResult.date ?? localResult.date,
      note: cloudResult.note ?? localResult.note,
    );
    return merged.isEmpty ? null : merged;
  }

  Future<int?> _convertForeignAmount(
    num? amount, {
    required String from,
    required String to,
  }) async {
    if (amount == null) return null;
    try {
      final result = await _conversionService.convertAmount(
        amount: amount,
        fromCurrency: from,
        toCurrency: to,
        use: ConversionUse.persist,
      );
      final converted = result.tryGetSuccess();
      if (converted == null || converted <= 0) {
        '[AI_PARSING] [GEMINI] 💱 Could not convert $amount $from to $to | amount left empty'
            .Log('ParseQuickEntryUseCase');
        return null;
      }
      '[AI_PARSING] [GEMINI] 💱 Converted $amount $from → $converted $to'.Log(
        'ParseQuickEntryUseCase',
      );
      return converted;
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  ParsedCloudItem? parseJsonResponse(
    String raw, {
    required Set<String> validCatIds,
    required Set<String> validWalletIds,
    required CurrencyDefinition currency,
  }) {
    try {
      final decoded = jsonDecode(_stripJsonFences(raw));
      if (decoded is! Map) return null;
      return _resolveItem(
        decoded,
        validCatIds: validCatIds,
        validWalletIds: validWalletIds,
        currency: currency,
      );
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  List<ParsedCloudItem?>? parseBatchJsonResponse(
    String raw, {
    required int imageCount,
    required Set<String> validCatIds,
    required Set<String> validWalletIds,
    required CurrencyDefinition currency,
  }) {
    try {
      final decoded = jsonDecode(_stripJsonFences(raw));
      final items = decoded is Map ? decoded['items'] : null;
      if (items is! List) return null;

      final slots = List<ParsedCloudItem?>.filled(imageCount, null);
      final claimed = <int>{};
      final ambiguous = <int>{};
      for (final entry in items) {
        if (entry is! Map) continue;
        final index = entry['imageIndex'];
        if (index is! int || index < 1 || index > imageCount) continue;
        if (!claimed.add(index)) {
          ambiguous.add(index);
          continue;
        }
        slots[index - 1] = _resolveItem(
          entry,
          validCatIds: validCatIds,
          validWalletIds: validWalletIds,
          currency: currency,
        );
      }
      for (final index in ambiguous) {
        slots[index - 1] = null;
      }
      return slots;
    } catch (_) {
      return null;
    }
  }

  String _stripJsonFences(String raw) =>
      raw.replaceAll(RegExp(r'```json|```'), '').trim();

  ParsedCloudItem _resolveItem(
    Map decoded, {
    required Set<String> validCatIds,
    required Set<String> validWalletIds,
    required CurrencyDefinition currency,
  }) {
    final amountValue = decoded['amount'];
    final statedCurrency = decoded['currencyCode'];
    final statedCode = statedCurrency is String
        ? statedCurrency.trim().toUpperCase()
        : null;
    final isForeignCurrency =
        statedCode != null &&
        _iso4217Pattern.hasMatch(statedCode) &&
        statedCode != currency.code;
    final positiveAmount = amountValue is num && amountValue > 0
        ? amountValue
        : null;
    final roundedAmount = positiveAmount?.round() ?? 0;
    final amount = !isForeignCurrency && roundedAmount > 0
        ? roundedAmount
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
      foreignCurrencyCode: isForeignCurrency ? statedCode : null,
      foreignAmount: isForeignCurrency ? positiveAmount : null,
    );
  }
}
