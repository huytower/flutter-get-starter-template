import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../profile/user_level/presentation/get_x/user_level_controller.dart';
import 'quick_entry_mixin.dart';

/// Sub-mixin handling camera & receipt scan image entry capabilities for quick transaction entry.
mixin QuickCameraEntryMixin on QuickEntryMixin {
  /// Reentrancy gate for receipt-photo entry — call before showing the
  /// source-picker sheet (not after) so the lock covers that whole round trip.
  bool beginQuickEntryImage() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
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

    '[AI_PARSING] 📸 Image picker started | fromCamera=$fromCamera'.Log(
      'QuickCameraEntryMixin',
    );
    final pickResult = await CcReceiptScanHelper.pickReceiptImage(
      fromCamera: fromCamera,
    );
    if (!isCurrentGeneration()) return;
    final picked = pickResult.image;
    if (picked == null) {
      '[AI_PARSING] ❌ No image picked'.Log('QuickCameraEntryMixin');
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
