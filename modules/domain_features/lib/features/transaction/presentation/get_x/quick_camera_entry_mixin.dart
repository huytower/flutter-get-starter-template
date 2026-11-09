import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../profile/user_level/presentation/get_x/user_level_controller.dart';
import 'quick_entry_mixin.dart';

/// Sub-mixin handling camera & receipt scan image entry capabilities for quick transaction entry.
mixin QuickCameraEntryMixin on QuickEntryMixin {
  /// Reentrancy gate for receipt-photo entry — call before showing the
  /// source-picker sheet (not after) so the lock covers that whole round trip.
  bool beginQuickEntryImage() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      '[AI_PARSING] [GEMINI] ⛔ Quick entry image blocked | VIP/Level requirement not met'
          .Log('QuickCameraEntryMixin');
      return false;
    }
    if (isParsingQuickEntry.value) return false;
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    return true;
  }

  /// Releases the lock [beginQuickEntryImage] took when the user dismissed
  /// the sheet without picking anything.
  void cancelQuickEntryImage() {
    isParsingQuickEntry.value = false;
  }

  /// Picks an image, runs on-device OCR, then feeds the result through the
  /// same local-parse/cloud-fallback pipeline as [submitQuickEntry].
  Future<void> submitQuickEntryFromImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    final (isCurrentGeneration, resetParsingIfCurrent) =
        trackQuickEntryGeneration();

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    final isGeminiEnabled = await prefs.isGeminiEnabled();
    if (!isGeminiEnabled) {
      '[AI_PARSING] [GEMINI] ⛔ Gemini AI disabled/offline | hiding camera button and aborting'
          .Log('QuickCameraEntryMixin');
      resetParsingIfCurrent();
      quickEntryErrorKey.value = CcLocaleKeys.report_ai_advice_gemini_disabled;
      return;
    }

    '[AI_PARSING] [GEMINI] 📸 Image picker started for Gemini AI | fromCamera=$fromCamera'
        .Log('QuickCameraEntryMixin');
    final pickResult = await CcReceiptScanHelper.pickReceiptImage(
      fromCamera: fromCamera,
    );
    if (!isCurrentGeneration()) return;
    final picked = pickResult.image;
    if (picked == null) {
      '[AI_PARSING] [GEMINI] ❌ Image pick cancelled or failed | permissionDenied=${pickResult.permissionDenied}'
          .Log('QuickCameraEntryMixin');
      resetParsingIfCurrent();
      if (pickResult.permissionDenied) {
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_photo_permission_denied;
      }
      return;
    }

    if (!context.mounted) {
      resetParsingIfCurrent();
      return;
    }
    await resolvePickedReceipt(context, picked);
  }
}
