import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/get_x/prj_get_controller.dart';
import '../../../../core/presentation/helper/transaction_form_helpers.dart';
import '../../../../core/quick_entry/quick_entry_intent.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import 'quick_entry_session.dart';
import 'transaction_controller.dart';

abstract class TransactionFormController extends PrjGetController {
  final RxString amountStr = '0'.obs;
  final TextEditingController noteController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final GlobalKey amountFieldKey = GlobalKey();

  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool hasSubmitting = false.obs;
  final RxBool showKeypad = false.obs;
  final RxBool showMoreDetails = false.obs;
  final RxBool hasNoteText = false.obs;
  final RxString currencyCode = CurrencyConstants.defaultCurrencyCode.obs;

  final Rx<String?> selectedWalletId = Rx<String?>(null);

  Worker? _walletsWorker;

  /// Set (via [loadForEdit]) when this controller instance is editing an
  /// existing transaction rather than recording a new one.
  TransactionEntity? editingTransaction;

  bool get hasEditing => editingTransaction != null;

  /// Called by [submitForm] after a successful edit — the edit sheet uses
  /// this to close itself instead of the create flow's reset-and-stay.
  VoidCallback? onEditSaved;

  @override
  void onInit() {
    super.onInit();
    _loadWallets();
    _loadCurrency();
    ever(CurrencyConstants.onCurrencyChanged, (_) => _loadCurrency());
    noteController.addListener(_updateNoteState);
    layoutStatus.value = CcLayoutStatus.success;
  }

  Future<void> _loadCurrency() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    currencyCode.value = settings.currencyCode;
  }

  void _updateNoteState() {
    hasNoteText.value = noteController.text.trim().isNotEmpty;
  }

  @override
  void onClose() {
    _walletsWorker?.dispose();
    noteController.removeListener(_updateNoteState);
    noteController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _loadWallets() {
    final parentController = Get.find<TransactionController>();
    wallets.assignAll(_liquidOnly(parentController.wallets));
    _ensureValidWalletSelection();

    // Listen to changes in parent's wallets
    _walletsWorker = ever(parentController.wallets, (
      List<WalletEntity> newWallets,
    ) {
      wallets.assignAll(_liquidOnly(newWallets));
      _ensureValidWalletSelection();
    });
  }

  /// Keeps [selectedWalletId] pointing at a wallet that still exists: a wallet
  /// can be deleted, or replaced by a Firestore sync, while this form is open
  /// (or before an old transaction is edited). A stale id would only fail later
  /// at save time, so fall back to the first available wallet instead.
  void _ensureValidWalletSelection() {
    final current = selectedWalletId.value;
    if (current != null && wallets.any((w) => w.id == current)) return;
    selectedWalletId.value = wallets.isNotEmpty ? wallets.first.id : null;
  }

  /// Prefills the form from [transaction] for editing. Category selection is
  /// left to the category picker itself (pass `transaction.categoryId` as
  /// its initial-selection id) so it resolves the real [CategoryEntity] from
  /// its own data source instead of reconstructing one from denormalized
  /// fields here.
  void loadForEdit(TransactionEntity transaction) {
    editingTransaction = transaction;
    amountStr.value = transaction.amount.toString();
    selectedWalletId.value = transaction.walletId;
    _ensureValidWalletSelection();
    date.value = transaction.date;
    noteController.text = transaction.note ?? '';
  }

  /// Investment positions (`WalletType.investment`) aren't spendable/receivable
  /// like a normal wallet, so they never appear as a liquid-wallet choice here.
  List<WalletEntity> _liquidOnly(List<WalletEntity> source) =>
      source.where((w) => w.type != WalletType.investment).toList();

  void handleKeyPress(String key) {
    if (amountStr.value == '0') {
      if (key != '0' && key != '000') {
        amountStr.value = key;
      }
    } else {
      amountStr.value += key;
    }
  }

  /// Quick-amount chips shown above the keypad and in the amount field.
  RxList<int> get quickAmounts;

  /// Clears the amount. Borrow and lend override it to clear an installment
  /// draft while one is being edited.
  void handleClear() => amountStr.value = '0';

  /// Applies a tapped quick amount (borrow and lend route it to a draft).
  void handleSuggestion(int value) => amountStr.value = value.toString();

  void handleDelete() {
    if (amountStr.value.length > 1) {
      amountStr.value = amountStr.value.substring(
        0,
        amountStr.value.length - 1,
      );
    } else {
      amountStr.value = '0';
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await TransactionFormHelpers.pickDate(context, date.value);
    if (picked == null) return;
    date.value = TransactionFormHelpers.updateDatePreserveTime(
      date.value,
      picked,
    );
  }

  String? composeNote() {
    return TransactionFormHelpers.composeNote(noteController);
  }

  Future<void> resetForm() async {
    amountStr.value = '0';
    noteController.clear();
    date.value = DateTime.now();
    showKeypad.value = false;
    _notifyParentKeypad(false);
    await onReset();
  }

  Future<void> onReset();

  void showKeypadAndScroll(BuildContext context, {GlobalKey? fieldKey}) {
    FocusScope.of(context).unfocus();
    showKeypad.value = true;
    _notifyParentKeypad(true);
    // Wait for the 200ms header collapse animation to complete before scrolling
    Future.delayed(const Duration(milliseconds: 220), () {
      final ctx = (fieldKey ?? amountFieldKey).currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void hideKeypad() {
    showKeypad.value = false;
    _notifyParentKeypad(false);
  }

  void _notifyParentKeypad(bool open) {
    if (Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().hasKeypadOpen.value = open;
    }
  }

  void setWalletId(String id) {
    if (wallets.any((w) => w.id == id)) {
      selectedWalletId.value = id;
    }
  }

  void toggleMoreDetails() {
    showMoreDetails.value = !showMoreDetails.value;
  }

  void setDate(DateTime newDate) {
    date.value = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      date.value.hour,
      date.value.minute,
    );
  }

  /// Refreshes all parent controllers concurrently using [Future.wait].
  Future<void> refreshParent() async {
    final futures = <Future<void>>[];

    if (Get.isRegistered<TransactionController>()) {
      final parent = Get.find<TransactionController>();
      futures.add(
        parent.refreshData().then((_) {
          parent.flashWalletSummary();
          _loadWallets();
        }),
      );
    }

    final refresh = getIt<FinancialRefreshProvider>();
    futures.addAll([
      refresh.refreshWallets(showLoading: false),
      refresh.refreshReport(showLoading: false),
      refresh.refreshBudgetLimits(),
      refresh.refreshLiabilityList(),
    ]);

    await Future.wait(futures);
  }

  /// The user came back to this form's tab. Refresh what can go stale while
  /// away (suggestions, regional amounts). Not called on the first visit: the
  /// form loads itself when it is built.
  void onTabActivated() {}

  /// The user moved to another tab.
  void onTabDeactivated() {}

  bool get canSubmit;

  void clearCategorySelection();

  void submitForm(BuildContext context);

  // ---------------------------------------------------------------------------
  // Quick entry: the controller owns a [QuickEntrySession]; these hooks tell it
  // how this form works. Override only what differs from the default.
  // ---------------------------------------------------------------------------

  QuickEntrySession get quickEntry;

  /// Category type quick entry searches and prefills within.
  String get quickEntryCategoryType;

  /// Further restricts [quickEntryCategoryType] to these `groupId`s (e.g. Loan
  /// only offers the selected direction's group). Null means every enabled
  /// category of that type.
  List<String>? get quickEntryCategoryGroupIds => null;

  /// Bumped to force the category picker to remount and resolve
  /// [pendingPrefillCategoryId] as its initial selection.
  RxInt get categoryKey;

  /// Set right before [categoryKey] is bumped so the remounted picker
  /// resolves this id (same mechanism edit mode uses).
  Rx<String?> get pendingPrefillCategoryId;

  /// Direction ('borrow' / 'lend') for dual-direction forms like Liability;
  /// the cross-tab intent switcher uses it within the same tab kind.
  String get quickEntryDirection => '';

  /// Applies form state for a detected intent (e.g. Investment "contribute").
  void applyQuickEntryIntent(QuickEntryIntent intent, String text) {}

  /// False for Investment, where [applyQuickEntryCategory] is a no-op — a
  /// resolved category would otherwise look tappable when it silently isn't.
  bool get quickEntryShowsCategoryInLabel => true;

  /// Whether this form has at least one row a parsed entry can be recorded
  /// against. Asset-backed forms (investment, borrow, lend) have none until the
  /// user creates an asset, so an entry there must not be auto-saved.
  bool get quickEntryHasSelectableCategory => true;

  /// Category ids a parsed entry may resolve to in this form.
  List<String> get quickEntryAvailableCategoryIds =>
      quickEntry.loadedCategoryIds;

  /// Applies a resolved category id to the picker. Investment overrides this
  /// as a no-op: its category always comes from the chosen asset.
  void applyQuickEntryCategory(String categoryId) =>
      quickEntry.applyCategoryDefault(categoryId);

  /// Applies a category resolved synchronously from the cache.
  void applyResolvedCategory(CategoryEntity category) {}
}
