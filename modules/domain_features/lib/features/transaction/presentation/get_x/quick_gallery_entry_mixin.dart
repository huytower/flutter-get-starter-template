import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../domain/entities/smart_entry_input.dart';
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

    '[AI_PARSING] ☁️ Escalating image to Gemini...'.Log(
      'QuickGalleryEntryMixin',
    );
    final cloud = await runSmartEntry(
      input: SmartEntryImagesInput([
        (bytes: picked.bytes, mimeType: picked.mimeType),
      ]),
      local: local,
      languageCode: languageCode,
    );
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    if (cloud.errorKey != null) {
      quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isNotEmpty) {
      if (context.mounted) await presentQuickEntryPreview(context, cloud.rows);
      return;
    }

    final suggestion = local;

    '[AI_PARSING] ↩️ Cloud returned nothing, using local OCR result | result=${suggestion.toJson()}'
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
