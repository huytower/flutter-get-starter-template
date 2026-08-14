import 'dart:async';

import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/budget_limit/export_budget_limit.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../guideline/guideline_controller.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/budget_over_limit_helper.dart';
import '../../../../core/helper/location_suggestion_helper.dart';
import '../../../../core/helper/merchant_match_helper.dart';
import '../../../../core/helper/time_based_suggestion_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
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
  /// — recomputed on every fresh blank form (init + after each reset) so it
  /// always reflects "now", not just whenever this singleton was created.
  /// Lowest priority in `_buildCategorySection`'s fallback chain — a merchant
  /// match, a location match, or an in-progress edit always wins.
  String? timeBasedSuggestedCategoryId;

  /// Phase 3.3 "AI Autofill" — the best fuzzy match (see
  /// [findBestMerchantMatch]) against the note text typed so far, offered as
  /// a one-tap suggestion. Null hides the suggestion affordance.
  final Rx<TransactionEntity?> merchantMatchSuggestion =
      Rx<TransactionEntity?>(null);

  /// Phase 3.5 location-based suggestion — the nearest past expense to the
  /// GPS fix taken when this form opened (see [findNearbyExpenseMatch]).
  /// Lower priority than [merchantMatchSuggestion] (a note match is a more
  /// specific signal than "you're near a place you've spent before") — only
  /// shown in the UI when the merchant match is empty. Set once per
  /// screen-open, not recomputed on every keystroke like the merchant match.
  final Rx<TransactionEntity?> locationMatchSuggestion =
      Rx<TransactionEntity?>(null);

  /// GPS fix captured for this screen-open, so [submitForm] can persist it on
  /// the new transaction for future location matching. Null when location
  /// was unavailable/denied or the gate/lookup hasn't resolved yet.
  double? _currentLat;
  double? _currentLng;

  List<TransactionEntity> _recentExpenses = [];
  Timer? _merchantMatchDebounce;

  @override
  bool get canSubmit =>
      selectedCategory.value != null &&
      selectedWalletId.value != null &&
      amountStr.value != '0' &&
      amountStr.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    timeBasedSuggestedCategoryId = suggestExpenseCategoryIdForHour(
      DateTime.now().hour,
    );
    noteController.addListener(_onNoteChanged);
    // Not calling refreshLocationSuggestion() here: ExpenseForm's initState
    // always calls it right after this controller is put/found (covers both
    // the fresh-instance case this onInit handles and the remount-without-
    // reinit case onInit can't see), so calling it here too would just fire
    // the GPS fix + recent-expenses fetch twice concurrently on every open.
  }

  @override
  void onClose() {
    _merchantMatchDebounce?.cancel();
    noteController.removeListener(_onNoteChanged);
    super.onClose();
  }

  @override
  void onReset() {
    selectedCategory.value = null;
    pendingPrefillCategoryId.value = null;
    merchantMatchSuggestion.value = null;
    timeBasedSuggestedCategoryId = suggestExpenseCategoryIdForHour(
      DateTime.now().hour,
    );
    categoryKey.value++;
    // The just-submitted transaction should be matchable for the very next
    // entry in this same session.
    refreshLocationSuggestion();
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
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
  }

  void dismissMerchantMatch() {
    merchantMatchSuggestion.value = null;
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
    final match = findNearbyExpenseMatch(
      lat: lat,
      lng: lng,
      candidates: candidates,
    );
    // A merchant match (typed after the location lookup resolved) is a more
    // specific signal — don't clobber it.
    if (merchantMatchSuggestion.value == null) {
      locationMatchSuggestion.value = match;
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
          final overResult = await getIt<GetBudgetOverLimitCountUseCase>()
              .call(categoryId);
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
