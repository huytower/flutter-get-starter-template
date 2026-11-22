import 'dart:async';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/quick_entry/quick_entry_parser_helper.dart';
import '../../domain/entities/smart_entry_input.dart';
import 'quick_entry_intent_router.dart';
import 'quick_entry_session.dart';

/// Typed quick entry: parses on-device while the user types (debounced) and
/// escalates to the cloud AI on submit. Owned by a [QuickEntrySession].
class QuickEntryTextInput {
  QuickEntryTextInput(this._session);

  final QuickEntrySession _session;
  Timer? _debounce;

  void dispose() => _debounce?.cancel();

  void onTextChanged() {
    _session.cancelAutoSaveCountdown();
    if (_session.isListeningQuickEntry.value) {
      // While dictating voice, ignore text change events to avoid launching duplicate parse timers
      return;
    }
    _session.quickEntryErrorKey.value = null;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _runLocalParse);
  }

  Future<void> _runLocalParse() async {
    if (!_session.handler.parser.canUseAiSmartEntry) return;
    final text = _session.quickEntryController.text.trim();
    if (text.isEmpty) {
      _session.quickEntrySuggestion.value = null;
      return;
    }

    if (await _session.handler.parser.aiPreferences.isGeminiEnabled()) {
      _session.quickEntrySuggestion.value = null;
      return;
    }

    '[AI_PARSING] [LOCAL] 🔍 Reactive parse started | tab=${_session.host.quickEntryCategoryType} | text="$text"'
        .Log('QuickEntryTextInput');

    // Text that belongs to another tab moves there and is parsed there.
    final intent = detectQuickEntryIntent(text);
    if (intent != null &&
        QuickEntryIntentRouter.routeOrApply(
          from: _session.host,
          intent: intent,
          text: text,
        )) {
      return;
    }

    final local = await _session.handler.parser.parseLocally(
      text,
      categoryType: _session.host.quickEntryCategoryType,
      groupIds: _session.host.quickEntryCategoryGroupIds,
    );
    if (_session.isQuickEntryDisposed ||
        text != _session.quickEntryController.text.trim()) {
      return;
    }

    // Ensure categories are loaded for the current tab before validating completeness.
    // This is crucial during tab-switches where the new controller was just initialized.
    if (_session.loadedCategoryIds.isEmpty) {
      await _session.refreshQuickEntryCategories();
    }

    // Score the fresh parse, not [_session.isQuickEntryCategoryMissing] — the Rx still
    // holds the previous keystroke's result at this point.
    final hasAmount = local.amount != null && local.amount! > 0;
    final categoryMissing = _session.isCategoryMissingFor(local);
    final isComplete = local.isComplete && !categoryMissing;

    // Publish the suggestion whenever an amount resolved, even if the category
    // didn't: the chip renders the "category missing (need +)" wording from
    // [isQuickEntryCategoryInvalid] instead of the success wording. Nulling it
    // here would leave the user with no feedback at all.
    _session.quickEntrySuggestion.value = hasAmount ? local : null;

    '[AI_PARSING] [LOCAL] ✅ Local parse completed | isComplete=$isComplete | categoryMissing=$categoryMissing | categoryId=${local.categoryId} | amount=${local.amount}'
        .Log('QuickEntryTextInput');

    // Proactive Prefill: Update form fields (amount and category) immediately
    // as the user types, so the form stays in sync with the visual recognition.
    if (local.amount != null) {
      _session.host.amountStr.value = local.amount!.toString();
    }
    if (local.categoryId != null && !categoryMissing) {
      _session.host.applyQuickEntryCategory(local.categoryId!);
    } else if (text.isNotEmpty) {
      // No usable category (never resolved, or no record in this tab carries
      // it). Clear any previous selection so the submit button stays disabled
      // until a valid category is found or picked by hand.
      _session.host.clearCategorySelection();
    }

    // Auto-save should only trigger if we have BOTH a valid category and a
    // non-zero amount.
    final bool canAutoSave =
        isComplete && hasAmount && local.categoryId != null;

    if (canAutoSave && Get.context != null) {
      _session.startAutoSaveTimer(Get.context!);
    }
  }

  /// Explicit "done" trigger (submit / finished voice dictation) — the only
  /// path that calls Gemini, so a network call never fires while someone
  /// is still mid-typing.
  Future<void> submitQuickEntry(BuildContext context) async {
    if (!_session.handler.parser.canUseAiSmartEntry) return;
    final languageCode = el.EasyLocalization.of(context)?.locale.languageCode;
    final prefs = _session.handler.parser.aiPreferences;
    final geminiEnabled = await prefs.isGeminiEnabled();
    final cloudAllowed = geminiEnabled && await prefs.isUnderDailyLimit();
    // Guards a fast double-submit from firing two concurrent cloud calls.
    if (_session.isParsingQuickEntry.value) return;
    final text = _session.quickEntryController.text.trim();
    if (text.isEmpty) return;

    '[AI_PARSING] [LOCAL] 🚀 Submitting quick entry | text="$text"'.Log(
      'QuickEntryTextInput',
    );

    // Text that belongs to another tab moves there; that tab submits it too
    // when the cloud AI is on.
    final intent = detectQuickEntryIntent(text);
    if (intent != null &&
        QuickEntryIntentRouter.routeOrApply(
          from: _session.host,
          intent: intent,
          text: text,
          afterHandOff: (target) {
            if (geminiEnabled) target.quickEntry.submitQuickEntry(context);
          },
        )) {
      return;
    }

    _debounce?.cancel();
    _session.quickEntryErrorKey.value = null;
    _session.isParsingQuickEntry.value = true;
    final (isCurrentGeneration, resetParsingIfCurrent) = _session
        .trackQuickEntryGeneration();

    final parseUseCase = _session.handler.parser;
    final local = await parseUseCase.parseLocally(
      text,
      categoryType: _session.host.quickEntryCategoryType,
      groupIds: _session.host.quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;
    '[AI_PARSING] [LOCAL] 📍 Local fallback ready | result=${local.toJson()}'
        .Log('QuickEntryTextInput');

    if (!cloudAllowed && local.amount != null) {
      '[AI_PARSING] [LOCAL] ✅ Local parse found amount | applying to form and starting auto-save'
          .Log('QuickEntryTextInput');
      resetParsingIfCurrent();

      // Proactively prefill form fields so the UI highlights the match immediately
      _session.host.amountStr.value = local.amount!.toString();
      if (local.categoryId != null && !_session.isCategoryMissingFor(local)) {
        _session.host.applyQuickEntryCategory(local.categoryId!);
      }

      // Published before the guard so the chip can render the missing-category
      // wording even when auto-save is blocked.
      _session.quickEntrySuggestion.value = local;
      if (_session.blockAutoSaveWhenNoCategory('local')) return;
      if (!_session.isQuickEntryCategoryMissing && context.mounted) {
        _session.startAutoSaveTimer(context);
      }
      return;
    }

    if (!context.mounted) return;

    '[AI_PARSING] [GEMINI] ☁️ Escalating to Gemini...'.Log(
      'QuickEntryTextInput',
    );
    final cloud = await _session.runSmartEntry(
      input: SmartEntryTextInput(text),
      local: local,
      languageCode: languageCode,
    );
    resetParsingIfCurrent();
    // The field stays editable during the round trip — re-check the text
    // still matches what was sent before applying/erroring on anything.
    if (!isCurrentGeneration() ||
        text != _session.quickEntryController.text.trim()) {
      '[AI_PARSING] [GEMINI] ⚠️ Generation stale after cloud call | aborting'
          .Log('QuickEntryTextInput');
      return;
    }

    if (cloud.errorKey != null) {
      _session.quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isNotEmpty) {
      if (context.mounted)
        await _session.presentQuickEntryPreview(context, cloud.rows);
      return;
    }

    final suggestion = local;

    '[AI_PARSING] [GEMINI] ↩️ Cloud returned nothing, using local result | result=${suggestion.toJson()}'
        .Log('QuickEntryTextInput');

    if (suggestion.isEmpty) {
      _session.quickEntryErrorKey.value =
          CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    // Apply proactive prefill for the cloud result
    if (suggestion.amount != null) {
      _session.host.amountStr.value = suggestion.amount!.toString();
    }
    if (suggestion.categoryId != null &&
        !_session.isCategoryMissingFor(suggestion)) {
      _session.host.applyQuickEntryCategory(suggestion.categoryId!);
    }

    // Published before the guard so the chip can render the missing-category
    // wording even when auto-save is blocked.
    _session.quickEntrySuggestion.value = suggestion;
    if (_session.blockAutoSaveWhenNoCategory('cloud')) return;
    if (!_session.isQuickEntryCategoryMissing && context.mounted) {
      _session.startAutoSaveTimer(context);
    }
  }
}
