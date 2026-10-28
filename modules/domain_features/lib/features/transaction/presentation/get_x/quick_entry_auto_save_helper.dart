import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class managing auto-save timer and countdown for quick entry forms.
class QuickEntryAutoSaveHelper {
  /// Feature flag to temporarily disable auto-save execution.
  /// Set to `true` when re-enabling auto-save in the near future.
  static const bool isAutoSaveEnabled = false;

  Timer? _timer;
  final RxInt autoSaveCountdown = 0.obs;

  /// Cancels any active auto-save timer and resets countdown state.
  void cancelAutoSave() {
    _timer?.cancel();
    _timer = null;
    autoSaveCountdown.value = 0;
  }

  /// Starts a 2-second countdown timer before executing [onElapsed].
  void startAutoSaveCountdown(VoidCallback onElapsed) {
    cancelAutoSave();
    if (!isAutoSaveEnabled) return;

    autoSaveCountdown.value = 2;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (autoSaveCountdown.value > 1) {
        autoSaveCountdown.value--;
      } else {
        cancelAutoSave();
        onElapsed();
      }
    });
  }

  /// Starts auto-save timer with validation checks.
  void startAutoSaveTimer({
    required BuildContext context,
    required bool hasSelectableCategory,
    required VoidCallback onSave,
  }) {
    if (!isAutoSaveEnabled) return;

    startAutoSaveCountdown(() {
      if (!hasSelectableCategory) return;
      onSave();
    });
  }
}
