import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import 'quick_entry_mixin.dart';

/// Sub-mixin handling receipt image resolution and OCR parsing for quick transaction entry.
mixin QuickGalleryEntryMixin on QuickEntryMixin {
  Future<void> resolvePickedReceipt(
    BuildContext context,
    PickedReceiptImage picked,
  ) async {
    final (isCurrentGeneration, resetParsingIfCurrent) =
        trackQuickEntryGeneration();
    final languageCode = el.EasyLocalization.of(context)?.locale.languageCode;

    '[AI_PARSING] 🔍 Running OCR...'.Log('QuickGalleryEntryMixin');
    final ocrText = await CcReceiptScanHelper.recognizeText(picked.path);
    if (!isCurrentGeneration()) return;
    '[AI_PARSING] 📝 OCR completed | textLength=${ocrText.length}'.Log(
      'QuickGalleryEntryMixin',
    );

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(
      ocrText,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;
    '[AI_PARSING] 📍 OCR-based local fallback ready | result=${local.toJson()}'
        .Log('QuickGalleryEntryMixin');

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    final cloudAllowed =
        await prefs.isGeminiEnabled() && await prefs.isUnderDailyLimit();
    if (!isCurrentGeneration()) return;
    if (!cloudAllowed && isAmountPlausible(local.amount)) {
      '[AI_PARSING] ✅ OCR parse found a plausible amount | cloud unavailable, using local result'
          .Log('QuickGalleryEntryMixin');
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      return;
    }

    if (!context.mounted) return;

    if (!await passQuickEntryCloudGate(
      context: context,
      isCurrentGeneration: isCurrentGeneration,
      resetParsingIfCurrent: resetParsingIfCurrent,
    )) {
      '[AI_PARSING] ⛔ Cloud gate blocked image escalation'.Log(
        'QuickGalleryEntryMixin',
      );
      return;
    }

    '[AI_PARSING] ☁️ Escalating image to Gemini...'.Log(
      'QuickGalleryEntryMixin',
    );
    final cloudResult = await parseUseCase.parseImageWithCloud(
      imageBytes: picked.bytes,
      mimeType: picked.mimeType,
      localResult: local,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
      languageCode: languageCode,
    );
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    final suggestion = (cloudResult != null && !cloudResult.isEmpty)
        ? cloudResult
        : local;

    '[AI_PARSING] ✨ Final image suggestion resolved | cloudSuccess=${cloudResult != null} | result=${suggestion.toJson()}'
        .Log('QuickGalleryEntryMixin');

    if (suggestion.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = suggestion;
    if (blockAutoSaveWhenNoCategory('image')) return;
    if (!isQuickEntryCategoryMissing && context.mounted) {
      startAutoSaveTimer(context);
    }
  }

  /// Sanity check for parsed amounts to avoid misidentifying phone numbers
  /// or serial numbers as transaction values.
  bool isAmountPlausible(int? amount) {
    if (amount == null) return false;
    const int threshold = 500000000;
    return amount > 0 && amount <= threshold;
  }
}
