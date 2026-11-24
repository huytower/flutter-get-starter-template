import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';
import 'package:permission_handler/permission_handler.dart';

import 'quick_entry_session.dart';

/// Voice quick entry: microphone permission, dictation into the quick-entry
/// field, and submitting when dictation ends. Owned by a [QuickEntrySession].
class QuickEntryVoiceInput {
  QuickEntryVoiceInput(this._session);

  final QuickEntrySession _session;

  Future<void> toggleVoiceQuickEntry(BuildContext context) async {
    if (!_session.handler.parser.canUseAiSmartEntry) return;

    '[VoiceWorkflow] 🟢 toggleVoiceQuickEntry triggered | isListening=${_session.hasListeningQuickEntry.value}'
        .Log('QuickEntryInput');

    bool voiceSubmitted = false;

    void triggerVoiceSubmit(String rawText, String source) {
      if (voiceSubmitted || _session.hasQuickEntryDisposed) return;
      voiceSubmitted = true;
      _session.hasListeningQuickEntry.value = false;
      _session.cancelAutoSaveCountdown();

      final text = rawText.trim();
      if (text.isNotEmpty && !_session.hasParsingQuickEntry.value) {
        '[VoiceWorkflow] 🚀 Submitting voice result via $source | text="$text"'
            .Log('QuickEntryInput');
        _session.submitQuickEntry(context);
      }
    }

    if (_session.hasListeningQuickEntry.value) {
      '[VoiceWorkflow] 🛑 Manual stop requested'.Log('QuickEntryInput');
      await _session.handler.speech.stopListening();
      triggerVoiceSubmit(_session.quickEntryController.text, 'manualStop');
      return;
    }

    final status = await Permission.microphone.request();
    '[VoiceWorkflow] 🔒 Microphone permission status: $status'.Log(
      'QuickEntryInput',
    );

    if (!status.isGranted) {
      _session.quickEntryErrorKey.value =
          PrjLocaleKeys.quick_entry_mic_permission_denied;
      return;
    }

    _session.host.hideKeypad();
    _session.quickEntryErrorKey.value = null;
    _session.hasListeningQuickEntry.value = true;

    final started = await _session.handler.speech.startListening(
      // Voice entry is tuned for Vietnamese amounts and phrases.
      localeId: 'vi_VN',
      onResult: (recognizedWords, hasFinal) {
        if (_session.hasQuickEntryDisposed) return;
        '[VoiceWorkflow] 🗣️ Voice recognized words: "$recognizedWords" | isFinal=$hasFinal'
            .Log('QuickEntryInput');

        _session.quickEntryController.text = recognizedWords;
        _session.quickEntryController.selection = TextSelection.collapsed(
          offset: recognizedWords.length,
        );
      },
      onListeningStopped: () {
        if (_session.hasQuickEntryDisposed) return;
        '[VoiceWorkflow] 🏁 Voice listening session completed'.Log(
          'QuickEntryInput',
        );
        triggerVoiceSubmit(
          _session.quickEntryController.text,
          'onListeningStopped',
        );
      },
    );

    if (_session.hasQuickEntryDisposed) return;

    if (!started) {
      if (!_session.handler.speech.hasListening) {
        '[VoiceWorkflow] ❌ Failed to start speech recognizer'.Log(
          'QuickEntryInput',
        );
        _session.hasListeningQuickEntry.value = false;
        _session.quickEntryErrorKey.value =
            PrjLocaleKeys.quick_entry_mic_permission_denied;
      }
    }
  }
}
