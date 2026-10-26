import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/di.dart';
import '../../../profile/user_level/presentation/get_x/user_level_controller.dart';
import 'quick_entry_mixin.dart';

/// Sub-mixin handling audio & speech dictation capabilities for quick transaction entry.
mixin QuickAudioEntryMixin on QuickEntryMixin {
  Future<void> toggleVoiceQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;

    '[VoiceWorkflow] 🟢 toggleVoiceQuickEntry triggered | isListening=${isListeningQuickEntry.value}'
        .Log('QuickAudioEntryMixin');

    bool voiceSubmitted = false;

    void triggerVoiceSubmit(String rawText, String source) {
      if (voiceSubmitted || isQuickEntryDisposed) return;
      voiceSubmitted = true;
      isListeningQuickEntry.value = false;
      cancelAutoSaveCountdown();

      final text = rawText.trim();
      if (text.isNotEmpty && !isParsingQuickEntry.value) {
        '[VoiceWorkflow] 🚀 Submitting voice result via $source | text="$text"'
            .Log('QuickAudioEntryMixin');
        submitQuickEntry(context);
      }
    }

    if (isListeningQuickEntry.value) {
      '[VoiceWorkflow] 🛑 Manual stop requested'.Log('QuickAudioEntryMixin');
      await CcSpeechHelper.stopListening();
      triggerVoiceSubmit(quickEntryController.text, 'manualStop');
      return;
    }

    final status = await Permission.microphone.request();
    '[VoiceWorkflow] 🔒 Microphone permission status: $status'.Log(
      'QuickAudioEntryMixin',
    );

    if (!status.isGranted) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_mic_permission_denied;
      return;
    }

    hideKeypad();
    quickEntryErrorKey.value = null;
    isListeningQuickEntry.value = true;

    final started = await CcSpeechHelper.startListening(
      onResult: (recognizedWords, isFinal) {
        if (isQuickEntryDisposed) return;
        '[VoiceWorkflow] 🗣️ Voice recognized words: "$recognizedWords" | isFinal=$isFinal'
            .Log('QuickAudioEntryMixin');

        quickEntryController.text = recognizedWords;
        quickEntryController.selection = TextSelection.collapsed(
          offset: recognizedWords.length,
        );

        if (isFinal) {
          triggerVoiceSubmit(recognizedWords, 'isFinal');
        }
      },
      onListeningStopped: () {
        if (isQuickEntryDisposed) return;
        '[VoiceWorkflow] 🏁 Voice listening session completed'.Log(
          'QuickAudioEntryMixin',
        );
        triggerVoiceSubmit(quickEntryController.text, 'onListeningStopped');
      },
    );

    if (isQuickEntryDisposed) return;

    if (!started) {
      if (!CcSpeechHelper.isListening) {
        '[VoiceWorkflow] ❌ Failed to start speech recognizer'.Log(
          'QuickAudioEntryMixin',
        );
        isListeningQuickEntry.value = false;
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_mic_permission_denied;
      }
    }
  }
}
