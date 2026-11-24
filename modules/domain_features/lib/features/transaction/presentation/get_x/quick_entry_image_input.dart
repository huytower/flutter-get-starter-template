import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../profile/presentation/widgets/ai_consent_sheet.dart';
import '../../domain/entities/parsed_transaction_entity.dart';
import '../../domain/entities/smart_entry_input.dart';
import '../helper/receipt_image_picker_helper.dart';
import 'quick_entry_session.dart';

/// Receipt-photo quick entry: consent, picking the image, sending it to the
/// cloud AI and showing the result. Owned by a [QuickEntrySession].
class QuickEntryImageInput {
  QuickEntryImageInput(this._session);

  final QuickEntrySession _session;

  /// Reentrancy gate for receipt-photo entry — call before showing the
  /// source-picker sheet (not after) so the lock covers that whole round
  /// trip, then follow with [submitQuickEntryFromImage] or
  /// [cancelQuickEntryImage].
  bool beginQuickEntryImage() {
    if (!_session.handler.parser.canUseAiSmartEntry) {
      return false;
    }
    if (_session.isParsingQuickEntry.value) return false;
    _session.quickEntryErrorKey.value = null;
    _session.isParsingQuickEntry.value = true;
    return true;
  }

  /// Releases the lock [beginQuickEntryImage] took when the user dismissed
  /// the sheet without picking anything.
  void cancelQuickEntryImage() {
    _session.isParsingQuickEntry.value = false;
  }

  /// Picks an image, runs on-device OCR, then feeds the result through the
  /// same local-parse/cloud-fallback pipeline as [_session.submitQuickEntry] — the
  /// cloud leg sends the image itself, not the OCR text, since receipt
  /// print is often too small/faded for OCR to be a trustworthy sole input.
  /// Assumes the caller already holds the lock via [beginQuickEntryImage].
  Future<void> submitQuickEntryFromImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    final (isCurrentGeneration, resetParsingIfCurrent) = _session
        .trackQuickEntryGeneration();

    // Scanning sends the photo to Gemini, so ask for consent first if the user
    // has not allowed AI data sharing yet.
    final isGeminiEnabled = await AiConsentSheet.ensure(
      context,
      _session.handler.parser.aiPreferences,
    );
    if (!isGeminiEnabled) {
      '[AI_PARSING] [GEMINI] ⛔ AI data sharing not allowed | aborting scan'.Log(
        'QuickEntryInput',
      );
      resetParsingIfCurrent();
      _session.quickEntryErrorKey.value =
          PrjLocaleKeys.report_ai_advice_gemini_disabled;
      return;
    }

    '[AI_PARSING] [GEMINI] 📸 Image picker started for Gemini AI | fromCamera=$fromCamera'
        .Log('QuickEntryInput');
    final pickResult = await ReceiptImagePickerHelper.pickReceiptImage(
      fromCamera: fromCamera,
    );
    if (!isCurrentGeneration()) return;
    final picked = pickResult.image;
    if (picked == null) {
      '[AI_PARSING] [GEMINI] ❌ Image pick cancelled or failed | permissionDenied=${pickResult.permissionDenied}'
          .Log('QuickEntryInput');
      resetParsingIfCurrent();
      // A denied permission gets explicit feedback; a plain cancel stays silent.
      if (pickResult.permissionDenied) {
        _session.quickEntryErrorKey.value =
            PrjLocaleKeys.quick_entry_photo_permission_denied;
      }
      return;
    }

    if (!context.mounted) {
      resetParsingIfCurrent();
      return;
    }
    await resolvePickedReceipt(context, picked);
  }

  Future<void> resolvePickedReceipt(
    BuildContext context,
    ReceiptImage picked,
  ) async {
    final (isCurrentGeneration, resetParsingIfCurrent) = _session
        .trackQuickEntryGeneration();
    final languageCode = el.EasyLocalization.of(context)?.locale.languageCode;

    if (!context.mounted) {
      resetParsingIfCurrent();
      return;
    }

    '[AI_PARSING] [GEMINI] ☁️ Direct image sending to Gemini AI parsing (No OCR) | bytes=${picked.bytes.length} mimeType=${picked.mimeType} lang=$languageCode'
        .Log('QuickEntryInput');
    final cloud = await _session.runSmartEntry(
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
          .Log('QuickEntryInput');
      _session.quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isNotEmpty) {
      '[AI_PARSING] [GEMINI] ✅ Gemini AI parsing succeeded | rowsCount=${cloud.rows.length} rows=${cloud.rows.map((r) => r.toJson()).toList()}'
          .Log('QuickEntryInput');
      if (context.mounted)
        await _session.presentQuickEntryPreview(context, cloud.rows);
      return;
    }

    '[AI_PARSING] [GEMINI] ⚠️ Gemini AI parsing returned 0 rows'.Log(
      'QuickEntryInput',
    );
    _session.quickEntryErrorKey.value =
        PrjLocaleKeys.quick_entry_could_not_parse;
  }
}
