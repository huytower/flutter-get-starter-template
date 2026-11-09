import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/parsed_transaction_entity.dart';
import '../../domain/entities/smart_entry_input.dart';
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

    if (!context.mounted) {
      resetParsingIfCurrent();
      return;
    }

    '[AI_PARSING] [GEMINI] ☁️ Direct image sending to Gemini AI parsing (No OCR) | bytes=${picked.bytes.length} mimeType=${picked.mimeType} lang=$languageCode'
        .Log('QuickGalleryEntryMixin');
    final cloud = await runSmartEntry(
      input: SmartEntryImagesInput([
        (bytes: picked.bytes, mimeType: picked.mimeType),
      ]),
      local: const ParsedTransactionEntity(),
      languageCode: languageCode,
    );
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    if (cloud.errorKey != null) {
      '[AI_PARSING] [GEMINI] ❌ Gemini AI parsing failed | errorKey=${cloud.errorKey}'
          .Log('QuickGalleryEntryMixin');
      quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isNotEmpty) {
      '[AI_PARSING] [GEMINI] ✅ Gemini AI parsing succeeded | rowsCount=${cloud.rows.length} rows=${cloud.rows.map((r) => r.toJson()).toList()}'
          .Log('QuickGalleryEntryMixin');
      if (context.mounted) await presentQuickEntryPreview(context, cloud.rows);
      return;
    }

    '[AI_PARSING] [GEMINI] ⚠️ Gemini AI parsing returned 0 rows'.Log(
      'QuickGalleryEntryMixin',
    );
    quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
  }

  /// Sanity check for parsed amounts to avoid misidentifying phone numbers
  /// or serial numbers as transaction values.
  bool isAmountPlausible(int? amount) {
    if (amount == null) return false;
    const int threshold = 500000000;
    return amount > 0 && amount <= threshold;
  }
}
