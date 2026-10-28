import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/ai/ai_language.dart';
import '../../../../core/ai/ai_prompts.dart';
import '../../../../core/ai/smart_entry_context.dart';
import '../../../../core/ai/smart_entry_response_parser.dart';
import '../../../../core/ai/smart_entry_schema.dart';
import '../../../../core/constant/currency_catalog.dart';
import '../../../../core/constant/currency_constants.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../../core/exchange_rates/exchange_rate_types.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../entities/parsed_transaction_entity.dart';
import '../entities/smart_entry_input.dart';

@lazySingleton
class ParseSmartEntryUseCase {
  ParseSmartEntryUseCase(this._getCategories, this._conversionService);

  static const int defaultMaxTransactions = 20;

  static const String geminiDisabledReason = 'gemini_disabled';
  static const String dailyLimitReachedReason = 'daily_limit_reached';

  final GetCategoriesUseCase _getCategories;
  final CurrencyConversionService _conversionService;

  WalletRepository get _walletRepository => getIt<WalletRepository>();

  Future<Result<List<ParsedTransactionEntity>, CcFailure>> call({
    required SmartEntryInput input,
    List<String> categoryTypes = const [CategoryType.expense],
    List<String>? groupIds,
    String? languageCode,
    int maxTransactions = defaultMaxTransactions,
    ParsedTransactionEntity? localResult,
  }) async {
    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.isGeminiEnabled()) {
      return const Error(ValidationFailure(geminiDisabledReason));
    }
    if (input is SmartEntryImagesInput && input.images.isEmpty) {
      return const Error(ValidationFailure('no_input'));
    }

    final categories = await _loadCategories(categoryTypes, groupIds);
    if (categories.isEmpty) {
      return const Error(ValidationFailure('no_categories'));
    }
    final wallets = liquidWallets(
      (await _walletRepository.getWallets()).tryGetSuccess() ?? [],
    );
    final currency = _primaryCurrency();
    final context = SmartEntryContext(
      types: categoryTypes,
      categories: [
        for (final c in categories)
          (id: c.id, label: el.tr(c.nameKey), type: c.type),
      ],
      wallets: [for (final w in wallets) (id: w.id, name: w.name)],
      currency: currency,
      language: resolveLanguageName(languageCode),
      today: DateTime.now(),
    );

    if (!await prefs.tryConsumeDailyCall()) {
      return const Error(ValidationFailure(dailyLimitReachedReason));
    }

    final response = await _generate(input, context, maxTransactions);
    if (response == null) {
      '[AI_PARSING] [GEMINI] ❌ Gemini returned null response'.Log(
        'ParseSmartEntryUseCase',
      );
      return const Error(ServerFailure('empty_response'));
    }
    '[AI_PARSING] [GEMINI] 📥 Gemini Response: $response'.Log(
      'ParseSmartEntryUseCase',
    );

    final raw = SmartEntryResponseParser.parse(
      response,
      context,
      maxTransactions: maxTransactions,
    );
    if (raw == null) return const Error(UnknownFailure('invalid_response'));

    return Success(
      await finalize(
        raw,
        currency: currency,
        defaultType: context.defaultType,
        localResult: localResult,
      ),
    );
  }

  Future<String?> _generate(
    SmartEntryInput input,
    SmartEntryContext context,
    int maxTransactions,
  ) {
    final isImages = input is SmartEntryImagesInput;
    final prompt = switch (input) {
      SmartEntryTextInput(:final text) => AiPrompts.smartEntryText(
        text: text,
        context: context,
        maxTransactions: maxTransactions,
      ),
      SmartEntryImagesInput(:final images) => AiPrompts.smartEntryImages(
        imageCount: images.length,
        context: context,
        maxTransactions: maxTransactions,
      ),
    };
    '[AI_PARSING] [GEMINI] ☁️ Gemini Prompt: \n$prompt'.Log(
      'ParseSmartEntryUseCase',
    );
    final schema = SmartEntrySchema.build(
      context,
      withDocumentKind: isImages,
      maxTransactions: maxTransactions,
    );
    return switch (input) {
      SmartEntryTextInput() => CcGeminiHelper.generateText(
        prompt: prompt,
        responseSchema: schema,
      ),
      SmartEntryImagesInput(:final images) => CcGeminiHelper.generateFromImages(
        images: images,
        prompt: prompt,
        responseSchema: schema,
      ),
    };
  }

  @visibleForTesting
  Future<List<ParsedTransactionEntity>> finalize(
    List<RawParsedTransaction> raw, {
    required CurrencyDefinition currency,
    required String defaultType,
    ParsedTransactionEntity? localResult,
  }) async {
    final converted = await Future.wait([
      for (final item in raw) _convert(item, currency),
    ]);
    final local = raw.length == 1 ? localResult : null;
    final merged = [
      for (var i = 0; i < converted.length; i++)
        _withLocal(converted[i], local, raw[i], defaultType),
    ];
    return merged.where((entity) => !entity.isEmpty).toList();
  }

  Future<ParsedTransactionEntity> _convert(
    RawParsedTransaction item,
    CurrencyDefinition currency,
  ) async {
    final foreignCode = item.foreignCurrencyCode;
    if (foreignCode == null) return item.entity;
    final amount = await _convertForeignAmount(
      item.foreignAmount,
      from: foreignCode,
      to: currency.code,
    );
    return item.entity.copyWith(amount: amount);
  }

  ParsedTransactionEntity _withLocal(
    ParsedTransactionEntity cloud,
    ParsedTransactionEntity? local,
    RawParsedTransaction raw,
    String defaultType,
  ) {
    if (local == null) return cloud;
    final sameType = cloud.type == null || cloud.type == defaultType;
    return ParsedTransactionEntity(
      type: cloud.type,
      amount: raw.foreignCurrencyCode == null
          ? cloud.amount ?? local.amount
          : cloud.amount,
      categoryId: cloud.categoryId ?? (sameType ? local.categoryId : null),
      walletId: cloud.walletId ?? local.walletId,
      date: cloud.date ?? local.date,
      note: cloud.note ?? local.note,
    );
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
            .Log('ParseSmartEntryUseCase');
        return null;
      }
      '[AI_PARSING] [GEMINI] 💱 Converted $amount $from → $converted $to'.Log(
        'ParseSmartEntryUseCase',
      );
      return converted;
    } catch (_) {
      return null;
    }
  }

  Future<List<CategoryEntity>> _loadCategories(
    List<String> categoryTypes,
    List<String>? groupIds,
  ) async {
    final result = await _getCategories.call();
    return result
            .tryGetSuccess()
            ?.where(
              (c) =>
                  c.isEnabled &&
                  categoryTypes.contains(c.type) &&
                  (groupIds == null || groupIds.contains(c.groupId)),
            )
            .toList() ??
        const <CategoryEntity>[];
  }

  @visibleForTesting
  List<WalletEntity> liquidWallets(List<WalletEntity> wallets) =>
      wallets.where((w) => w.type != WalletType.investment).toList();

  CurrencyDefinition _primaryCurrency() =>
      CurrencyCatalog.getDefinition(CurrencyConstants.currentPrimaryCurrency);

  @visibleForTesting
  String resolveLanguageName(String? languageCode) =>
      AiLanguage.nameOf(languageCode);
}
