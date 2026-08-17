import 'dart:async';

import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/budget_limit/export_budget_limit.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../../core/helper/budget_over_limit_helper.dart';
import '../../../../core/helper/location_suggestion_helper.dart';
import '../../../../core/helper/merchant_match_helper.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../../core/helper/time_based_suggestion_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../widgets/cloud_consent_sheet.dart';
import 'transaction_form_controller.dart';

@injectable
class ExpenseFormController extends TransactionFormController {
  ExpenseFormController(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final RxInt categoryKey = 0.obs;

  /// Set right before [categoryKey] is bumped by [applyMerchantMatch] or
  /// [applyLocationMatch], so the remounted `CategorySelectionSection`
  /// resolves and reports back the real [CategoryEntity] for this id — same
  /// mechanism edit-mode already uses via `editingTransaction?.categoryId`.
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  /// Phase 3.2 time-based suggestion (see [suggestExpenseCategoryIdForHour])
  /// — recomputed by [refreshTimeBasedSuggestion] so it always reflects
  /// "now", not just whenever this singleton was created or last reset.
  /// Lowest priority in `_buildCategorySection`'s fallback chain — a merchant
  /// match, a location match, or an in-progress edit always wins.
  String? timeBasedSuggestedCategoryId;

  /// Phase 3.3 "AI Autofill" — the best fuzzy match (see
  /// [findBestMerchantMatch]) against the note text typed so far, offered as
  /// a one-tap suggestion. Null hides the suggestion affordance.
  final Rx<TransactionEntity?> merchantMatchSuggestion = Rx<TransactionEntity?>(
    null,
  );

  /// Phase 3.5 location-based suggestion — the nearest past expense to the
  /// GPS fix taken when this form opened (see [findNearbyExpenseMatch]).
  /// Lower priority than [merchantMatchSuggestion] (a note match is a more
  /// specific signal than "you're near a place you've spent before") — only
  /// shown in the UI when the merchant match is empty. Set once per
  /// screen-open, not recomputed on every keystroke like the merchant match.
  final Rx<TransactionEntity?> locationMatchSuggestion = Rx<TransactionEntity?>(
    null,
  );

  /// GPS fix captured for this screen-open, so [submitForm] can persist it on
  /// the new transaction for future location matching. Null when location
  /// was unavailable/denied or the gate/lookup hasn't resolved yet.
  double? _currentLat;
  double? _currentLng;

  /// The last GPS-derived nearby-expense match computed this screen-open,
  /// kept regardless of whether it's currently suppressed by a merchant
  /// match — so it can be re-surfaced once that merchant match clears
  /// instead of being permanently lost (see [_publishLocationMatch]).
  TransactionEntity? _lastLocationMatch;

  List<TransactionEntity> _recentExpenses = [];
  Timer? _merchantMatchDebounce;

  /// Phase 3.6 "NLP Simple" quick entry — free text or dictated speech like
  /// "50k cafe", parsed locally first (see [ParseQuickEntryUseCase]) with a
  /// consent-gated, daily-capped cloud fallback when the local parse can't
  /// determine both fields. Only ever non-null when both amount and
  /// category are resolved — same "prefill, user still confirms" contract
  /// as [merchantMatchSuggestion]/[locationMatchSuggestion], applied via
  /// [applyQuickEntryParse].
  final TextEditingController quickEntryController = TextEditingController();
  final Rx<QuickEntryParseResult?> quickEntrySuggestion =
      Rx<QuickEntryParseResult?>(null);
  final RxBool isParsingQuickEntry = false.obs;
  final RxBool isListeningQuickEntry = false.obs;

  /// Locale key for an inline status message (e.g. "couldn't understand" /
  /// "daily AI limit reached") — null means no message to show.
  final Rx<String?> quickEntryErrorKey = Rx<String?>(null);

  List<CategoryEntity> _expenseCategoriesForQuickEntry = [];
  Timer? _quickEntryDebounce;
  bool _isDisposed = false;

  /// Bumped by [onReset] to invalidate any quick-entry submission still
  /// in flight (e.g. an abandoned cloud call from a transaction the user
  /// already saved and moved on from). A stale submission's continuation
  /// recognizes it's no longer current generation and skips touching
  /// [isParsingQuickEntry] itself — letting [onReset] safely reset that
  /// flag immediately for the next entry without a late-arriving stale
  /// result re-disabling it or, worse, racing a brand new submission that
  /// started in the meantime (which would reintroduce the very
  /// double-submit hazard [submitQuickEntry]'s reentrancy guard exists to
  /// prevent).
  int _quickEntryGeneration = 0;

  @override
  bool get canSubmit =>
      selectedCategory.value != null &&
      selectedWalletId.value != null &&
      amountStr.value != '0' &&
      amountStr.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    refreshTimeBasedSuggestion();
    noteController.addListener(_onNoteChanged);
    quickEntryController.addListener(_onQuickEntryTextChanged);
    _loadExpenseCategoriesForQuickEntry();
    // Not calling refreshLocationSuggestion() here: ExpenseForm's initState
    // always calls it right after this controller is put/found (covers both
    // the fresh-instance case this onInit handles and the remount-without-
    // reinit case onInit can't see), so calling it here too would just fire
    // the GPS fix + recent-expenses fetch twice concurrently on every open.
  }

  @override
  void onClose() {
    _isDisposed = true;
    _merchantMatchDebounce?.cancel();
    _quickEntryDebounce?.cancel();
    noteController.removeListener(_onNoteChanged);
    quickEntryController
      ..removeListener(_onQuickEntryTextChanged)
      ..dispose();
    // Only stop the (global, singleton) recognizer if this instance is the
    // one actually holding it — e.g. an edit sheet dismissed mid-dictation
    // shouldn't cut off a still-active session on the entry tab.
    if (isListeningQuickEntry.value) {
      CcSpeechHelper.stopListening();
    }
    super.onClose();
  }

  @override
  void onReset() {
    selectedCategory.value = null;
    pendingPrefillCategoryId.value = null;
    merchantMatchSuggestion.value = null;
    quickEntrySuggestion.value = null;
    quickEntryErrorKey.value = null;
    quickEntryController.clear();
    // Invalidates any quick-entry submission still awaiting the cloud
    // fallback (see _quickEntryGeneration's doc) and safely reclaims the
    // "busy" flag for the next entry immediately, rather than leaving it
    // disabled until that abandoned call happens to finish.
    _quickEntryGeneration++;
    isParsingQuickEntry.value = false;
    refreshTimeBasedSuggestion();
    categoryKey.value++;
    // The just-submitted transaction should be matchable for the very next
    // entry in this same session.
    refreshLocationSuggestion();
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    // Manual selection clears any pending prefill from AI suggestions
    // so it doesn't clobber the user's choice on the next rebuild.
    pendingPrefillCategoryId.value = null;
  }

  /// Recomputes [timeBasedSuggestedCategoryId] for "now" — call whenever the
  /// Expense form becomes visible again (e.g. the user switches to another
  /// bottom-nav tab and comes back), same "persistent singleton, onInit only
  /// fires once" reason as [refreshLocationSuggestion]. Unlike that method
  /// this is synchronous and cheap, so it's safe to call directly from
  /// `initState` before the first build rather than needing an awaited
  /// refresh.
  void refreshTimeBasedSuggestion() {
    timeBasedSuggestedCategoryId = suggestExpenseCategoryIdForHour(
      DateTime.now().hour,
    );
  }

  Future<void> _loadRecentExpenses() async {
    final result = await _transactionRepository.getTransactions(
      const PaginationRequest(page: 1, itemsPerPage: 100),
    );
    result.when((transactions) {
      _recentExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .toList();
    }, (_) {});
  }

  void _onNoteChanged() {
    _merchantMatchDebounce?.cancel();
    _merchantMatchDebounce = Timer(
      const Duration(milliseconds: 400),
      _runMerchantMatch,
    );
  }

  void _runMerchantMatch() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return;
    }
    final candidates = _recentExpenses
        .where((t) => (t.note ?? '').trim().isNotEmpty)
        .toList();
    final match = findBestMerchantMatch(
      query: noteController.text,
      candidates: candidates,
    );
    merchantMatchSuggestion.value = match;
    // A merchant match here supersedes any cached location match; typing
    // past one (e.g. clearing the note) should let it reappear rather than
    // stay lost for the rest of the screen-open.
    _publishLocationMatch();
  }

  void dismissMerchantMatch() {
    merchantMatchSuggestion.value = null;
    _publishLocationMatch();
  }

  /// Pre-fills category/amount/wallet from the fuzzy-matched past expense —
  /// same "prefill, user still confirms" contract as [applyTemplate].
  void applyMerchantMatch(TransactionEntity match) {
    amountStr.value = match.amount.toString();
    if (wallets.any((w) => w.id == match.walletId)) {
      selectedWalletId.value = match.walletId;
    }
    pendingPrefillCategoryId.value = match.categoryId;
    categoryKey.value++;
    merchantMatchSuggestion.value = null;
    locationMatchSuggestion.value = null;
  }

  /// Re-runs the location lookup — call whenever the Expense form becomes
  /// visible again (e.g. the user switches to another bottom-nav tab and
  /// comes back). This controller is a persistent singleton kept alive for
  /// the whole session, so `onInit` only ever fires once; without an
  /// explicit re-check on each screen-open, a GPS fix taken at app-launch
  /// (or wherever the last submit happened) would silently keep being used
  /// forever, never reflecting the user's actual current location. Also
  /// reloads [_recentExpenses] first so a same-session just-submitted
  /// expense is immediately matchable — the previous version relied on a
  /// separately-chained reload that could race behind this call on the very
  /// first app-session open, silently matching against an empty list.
  Future<void> refreshLocationSuggestion() async {
    locationMatchSuggestion.value = null;
    _lastLocationMatch = null;
    _currentLat = null;
    _currentLng = null;
    await _loadRecentExpenses();
    await _loadLocationSuggestion();
  }

  /// Foreground-only GPS fix + nearest-past-expense lookup (see
  /// [findNearbyExpenseMatch]). Gated the same way as merchant match — skips
  /// entirely for LV1/2 users. A denied/unavailable fix silently leaves both
  /// [_currentLat]/[_currentLng] and the suggestion null; never blocks the
  /// form or prompts more than once per screen-open.
  ///
  /// Checks the OS's cached last-known position first — it resolves near
  /// instantly, so the suggestion can appear right as the form opens instead
  /// of waiting the several seconds a fresh GPS lock can take — then refines
  /// with a real fix afterward, since that's also what gets persisted on
  /// submit and should be as accurate as possible.
  Future<void> _loadLocationSuggestion() async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return;
    }

    final lastKnown = await CcLocationHelper.getLastKnownPosition();
    if (lastKnown != null) {
      _applyLocationFix(lastKnown.latitude, lastKnown.longitude);
    }

    final position = await CcLocationHelper.getCurrentPosition();
    if (position != null) {
      _applyLocationFix(position.latitude, position.longitude);
    }
  }

  void _applyLocationFix(double lat, double lng) {
    _currentLat = lat;
    _currentLng = lng;

    final candidates = _recentExpenses
        .where((t) => t.lat != null && t.lng != null)
        .toList();
    // Always cache the computed match, even when a merchant match is
    // currently suppressing it — otherwise the location match is discarded
    // outright (this runs at most twice per screen-open) instead of being
    // re-offered once the merchant match clears (see _publishLocationMatch).
    _lastLocationMatch = findNearbyExpenseMatch(
      lat: lat,
      lng: lng,
      candidates: candidates,
    );
    _publishLocationMatch();
  }

  /// A merchant match is a more specific signal than "you're near a place
  /// you've spent before" — shows the cached location match only when no
  /// merchant match is currently active.
  void _publishLocationMatch() {
    if (merchantMatchSuggestion.value == null) {
      locationMatchSuggestion.value = _lastLocationMatch;
    }
  }

  void dismissLocationMatch() {
    locationMatchSuggestion.value = null;
  }

  /// Pre-fills category/amount/wallet from the nearest past expense at this
  /// location — same "prefill, user still confirms" contract as
  /// [applyMerchantMatch].
  void applyLocationMatch(TransactionEntity match) {
    amountStr.value = match.amount.toString();
    if (wallets.any((w) => w.id == match.walletId)) {
      selectedWalletId.value = match.walletId;
    }
    pendingPrefillCategoryId.value = match.categoryId;
    categoryKey.value++;
    locationMatchSuggestion.value = null;
    _lastLocationMatch = null;
  }

  Future<void> _loadExpenseCategoriesForQuickEntry() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    _expenseCategoriesForQuickEntry =
        result
            .tryGetSuccess()
            ?.where((c) => c.isEnabled && c.type == CategoryType.expense)
            .toList() ??
        [];
  }

  CategoryEntity? _findQuickEntryCategory(String id) {
    for (final c in _expenseCategoriesForQuickEntry) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Display label for a resolved (i.e. [QuickEntryParseResult.isComplete])
  /// suggestion, e.g. "50.00k · Cà phê" — mirrors `_formatSuggestionLabel`
  /// in `expense_form.dart` for the merchant/location chips.
  String quickEntryResultLabel(QuickEntryParseResult result) {
    final category = _findQuickEntryCategory(result.categoryId!);
    final categoryLabel = category != null ? el.tr(category.nameKey) : '';
    return '${formatVndShort(result.amount!)}đ · $categoryLabel';
  }

  void _onQuickEntryTextChanged() {
    quickEntryErrorKey.value = null;
    _quickEntryDebounce?.cancel();
    _quickEntryDebounce = Timer(
      const Duration(milliseconds: 400),
      _runLocalQuickEntryParse,
    );
  }

  Future<void> _runLocalQuickEntryParse() async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    final text = quickEntryController.text.trim();
    if (text.isEmpty) {
      quickEntrySuggestion.value = null;
      return;
    }
    final local = await getIt<ParseQuickEntryUseCase>().parseLocally(text);
    if (_isDisposed || text != quickEntryController.text.trim()) return;
    quickEntrySuggestion.value = local.isComplete ? local : null;
  }

  /// Explicit "done" trigger (text field submit, or a finished voice
  /// dictation) — unlike the as-you-type local-only debounce above, this is
  /// the sole path that may escalate to the consent-gated, daily-capped
  /// cloud fallback, so a network call only ever fires on a deliberate user
  /// action, never silently while someone is still mid-typing.
  Future<void> submitQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    // Reentrancy guard: without this, a fast double-submit (double-tap
    // Enter while the first call is still awaiting the cloud round trip, or
    // voice auto-submit racing a manual submit) would fire two concurrent
    // cloud calls and desync `quickEntrySuggestion` between them.
    if (isParsingQuickEntry.value) return;
    final text = quickEntryController.text.trim();
    if (text.isEmpty) return;

    _quickEntryDebounce?.cancel();
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    // Captured once at the start of this specific submission — see
    // _quickEntryGeneration's doc. [onReset] bumps the counter to
    // invalidate an abandoned in-flight submission (e.g. the user already
    // saved the transaction and moved on) without this call clobbering
    // state that a newer submission now owns.
    final generation = _quickEntryGeneration;
    bool isCurrentGeneration() =>
        !_isDisposed && generation == _quickEntryGeneration;
    void resetParsingIfCurrent() {
      if (isCurrentGeneration()) isParsingQuickEntry.value = false;
    }

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(text);
    if (!isCurrentGeneration()) return;

    if (local.isComplete) {
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      return;
    }

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.isConsentGiven()) {
      final agreed = await _promptCloudConsent(context);
      if (!isCurrentGeneration()) return;
      if (!agreed) {
        resetParsingIfCurrent();
        quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
        return;
      }
      await prefs.setConsentGiven(true);
    }

    // Atomically checks-and-reserves a slot under the daily cap — see
    // AiFallbackPreferenceDataSource.tryConsumeDailyCall's doc for why a
    // separate isUnderDailyLimit()+incrementTodayFallbackCount() pair would
    // be a check-then-act race across concurrent callers.
    if (!await prefs.tryConsumeDailyCall()) {
      if (!isCurrentGeneration()) return;
      resetParsingIfCurrent();
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_daily_limit_reached;
      return;
    }

    final cloudResult = await parseUseCase.parseWithCloud(
      text: text,
      localResult: local,
    );
    resetParsingIfCurrent();
    // The text field stays editable throughout this round trip (the mic
    // and submit are locked, but typing isn't blocked) — re-check the text
    // still matches what was actually sent before applying anything, same
    // as the local-parse leg already does. Without this, a slow cloud
    // response could land after the user cleared the field or started a
    // different entry and silently pop up a suggestion for stale text.
    if (!isCurrentGeneration() || text != quickEntryController.text.trim()) {
      return;
    }

    if (cloudResult == null || !cloudResult.isComplete) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = cloudResult;
  }

  /// Reentrancy gate for Phase 3.7 receipt-photo entry. Must be called (and,
  /// on success, followed by either [submitQuickEntryFromImage] or
  /// [cancelQuickEntryImage]) *before* showing the take-photo/choose-gallery
  /// sheet — not after it resolves — so the lock covers that whole UI round
  /// trip, not just the OCR/cloud portion. [submitQuickEntry] closes the
  /// equivalent window for free by checking-then-setting [isParsingQuickEntry]
  /// with no `await` in between; the photo path needs an explicit method to
  /// get the same property since a whole sheet interaction sits between "user
  /// tapped scan" and "we know which image to process."
  bool beginQuickEntryImage() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return false;
    }
    if (isParsingQuickEntry.value) return false;
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    return true;
  }

  /// Releases the lock [beginQuickEntryImage] took, for when the user
  /// dismissed the source-selection sheet without picking anything.
  void cancelQuickEntryImage() {
    isParsingQuickEntry.value = false;
  }

  /// Phase 3.7 receipt-photo entry — picks an image (camera or gallery),
  /// runs on-device OCR, then feeds the recognized text through the exact
  /// same local-parse/cloud-fallback pipeline [submitQuickEntry] uses for
  /// typed/dictated text, landing in the same [quickEntrySuggestion] so the
  /// UI needs no separate suggestion state or chip. The cloud leg sends the
  /// image itself (see [ParseQuickEntryUseCase.parseImageWithCloud]), not
  /// the OCR text, since receipt print is small/faded enough that OCR often
  /// can't be trusted as the sole cloud input.
  ///
  /// Assumes the caller already holds the [isParsingQuickEntry] lock via a
  /// successful [beginQuickEntryImage] call.
  Future<void> submitQuickEntryFromImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    final generation = _quickEntryGeneration;
    bool isCurrentGeneration() =>
        !_isDisposed && generation == _quickEntryGeneration;
    void resetParsingIfCurrent() {
      if (isCurrentGeneration()) isParsingQuickEntry.value = false;
    }

    final pickResult = await CcReceiptScanHelper.pickReceiptImage(
      fromCamera: fromCamera,
    );
    if (!isCurrentGeneration()) return;
    final picked = pickResult.image;
    if (picked == null) {
      resetParsingIfCurrent();
      // A denied permission gets explicit feedback (with a path to fix it
      // via Settings); a plain cancel/unreadable-file stays silent, same as
      // every other quick-entry failure mode.
      if (pickResult.permissionDenied) {
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_photo_permission_denied;
      }
      return;
    }

    final ocrText = await CcReceiptScanHelper.recognizeText(picked.path);
    if (!isCurrentGeneration()) return;

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(ocrText);
    if (!isCurrentGeneration()) return;

    if (local.isComplete) {
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      return;
    }

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.isConsentGiven()) {
      final agreed = await _promptCloudConsent(context);
      if (!isCurrentGeneration()) return;
      if (!agreed) {
        resetParsingIfCurrent();
        quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
        return;
      }
      await prefs.setConsentGiven(true);
    }

    if (!await prefs.tryConsumeDailyCall()) {
      if (!isCurrentGeneration()) return;
      resetParsingIfCurrent();
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_daily_limit_reached;
      return;
    }

    final cloudResult = await parseUseCase.parseImageWithCloud(
      imageBytes: picked.bytes,
      mimeType: picked.mimeType,
      localResult: local,
    );
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    if (cloudResult == null || !cloudResult.isComplete) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = cloudResult;
  }

  Future<bool> _promptCloudConsent(BuildContext context) async {
    final result = await CloudConsentSheet.show(context);
    return result ?? false;
  }

  Future<void> toggleVoiceQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    if (isListeningQuickEntry.value) {
      await CcSpeechHelper.stopListening();
      isListeningQuickEntry.value = false;
      return;
    }

    hideKeypad();
    quickEntryErrorKey.value = null;
    isListeningQuickEntry.value = true;
    final started = await CcSpeechHelper.startListening(
      onResult: (recognizedWords, isFinal) {
        if (_isDisposed) return;
        quickEntryController.text = recognizedWords;
        quickEntryController.selection = TextSelection.collapsed(
          offset: recognizedWords.length,
        );
        if (isFinal) {
          isListeningQuickEntry.value = false;
          submitQuickEntry(context);
        }
      },
      // The recognizer can stop itself (e.g. a silence timeout) without
      // ever delivering a final result — without this, isListeningQuickEntry
      // would never reset in that case and the mic icon would stay showing
      // "actively listening" until the user taps it again.
      onListeningStopped: () {
        if (_isDisposed) return;
        isListeningQuickEntry.value = false;
      },
    );
    if (_isDisposed) return;
    if (!started) {
      isListeningQuickEntry.value = false;
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_mic_permission_denied;
    }
  }

  /// Pre-fills category/amount from a resolved quick-entry parse — same
  /// "prefill, user still confirms" contract as [applyMerchantMatch].
  void applyQuickEntryParse(QuickEntryParseResult result) {
    amountStr.value = result.amount!.toString();
    pendingPrefillCategoryId.value = result.categoryId;
    categoryKey.value++;
    quickEntrySuggestion.value = null;
    quickEntryController.clear();
  }

  void dismissQuickEntrySuggestion() {
    quickEntrySuggestion.value = null;
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final categoryId = selectedCategory.value?.id ?? '';
    final categoryLabel = selectedCategory.value != null
        ? el.tr(selectedCategory.value!.nameKey)
        : '';
    final amount = int.tryParse(amountStr.value) ?? 0;

    final result = isEditing
        ? await getIt<UpdateTransactionUseCase>().call(
            UpdateTransactionParams(
              original: editingTransaction!,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
            ),
          )
        : await getIt<CreateTransactionUseCase>().call(
            CreateTransactionParams(
              type: TransactionType.expense,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
              lat: _currentLat,
              lng: _currentLng,
            ),
          );
    isSubmitting.value = false;

    result.when(
      (_) async {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );

        BudgetOverLimitEntity? overLimit;
        if (categoryId.isNotEmpty) {
          final overResult = await getIt<GetBudgetOverLimitCountUseCase>().call(
            categoryId,
          );
          overLimit = overResult.tryGetSuccess();
        }
        // Phase 3.4 threshold notifications — new expenses only; an edit's
        // before/after spend delta isn't simply the edited amount, so
        // recomputing a correct crossing for edits is left for later.
        if (categoryId.isNotEmpty && !isEditing) {
          getIt<CheckBudgetThresholdUseCase>().call(
            categoryId: categoryId,
            transactionAmount: amount,
          );
        }
        if (!context.mounted) return;

        if (overLimit != null) {
          CcSnackBarHelper.showSnackBar(
            context: context,
            message: el.tr(
              CcLocaleKeys.budget_over_limit_count,
              namedArgs: {
                'name': overLimit.budgetName,
                'count': '${overLimit.count}',
              },
            ),
            textColor: budgetOverLimitColor(
              overLimit.count,
              context.ccColorScheme,
            ),
          );
        } else {
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(
              isEditing
                  ? CcLocaleKeys.transaction_expense_updated
                  : CcLocaleKeys.transaction_expense_saved,
              namedArgs: {'amount': savedAmount},
            ),
          );
        }
        if (isEditing) {
          onEditSaved?.call();
        } else {
          resetForm();
        }
        refreshParent();
        // Guideline: first_transaction completed
        Get.find<GuidelineController>().completeTask('first_transaction');
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
