import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/presentation/helper/horizontal_row_reveal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../transaction/presentation/get_x/quick_entry_handler.dart';
import '../../../transaction/presentation/get_x/quick_entry_session.dart';
import '../../../transaction/presentation/get_x/transaction_form_controller.dart';
import '../../domain/entities/liability_balance_entity.dart';
import 'liability_installment_draft.dart';

enum LiabilityDirectionForm { increase, decrease }

const String _debugTag = 'LiabilityAssetRow';

abstract class LiabilityBaseFormController extends TransactionFormController {
  LiabilityBaseFormController(this.quickEntryHandler);

  final QuickEntryHandler quickEntryHandler;

  @override
  late final QuickEntrySession quickEntry = QuickEntrySession(
    this,
    quickEntryHandler,
  );

  RxList<LiabilityBalanceEntity> get mergedItems;

  RxBool get isLoadingMerged;

  RxnString get selectedLiabilityId;

  RxList<LiabilityInstallmentDraft> get installmentDrafts;

  RxnInt get editingInstallmentIndex;

  RxBool get reminderBeforeDueDate;

  RxString get repaymentMethod;

  Rx<DateTime?> get finalDueDate;

  int get principalAmount;

  int get installmentsTotal;

  bool get canAddInstallment;

  String get direction;

  Rx<LiabilityDirectionForm> get action;

  void setAction(LiabilityDirectionForm value);

  /// The listed balance of the selected liability, if one is selected.
  LiabilityBalanceEntity? get selectedBalance => mergedItems.firstWhereOrNull(
    (b) => b.liability.id == selectedLiabilityId.value,
  );

  /// Whether a repay / collect amount is more than what is still owed, so the
  /// form can say so and keep Save off.
  ///
  /// A settled (or over-collected) liability takes no amount at all, in any
  /// currency. Otherwise the amount is compared only when the liability is in
  /// the currency it is typed in; for another currency
  /// `RecordLiabilityPaymentUseCase` checks the converted amount on save.
  bool get exceedsOutstanding {
    final balance = selectedBalance;
    if (balance == null || action.value != LiabilityDirectionForm.decrease) {
      return false;
    }
    final amount = int.tryParse(amountStr.value) ?? 0;
    if (amount <= 0) return false;
    if (balance.isSettled) return true;
    if (balance.liability.currencyCode.toUpperCase() !=
        CurrencyConstants.currentPrimaryCurrency.toUpperCase()) {
      return false;
    }
    return amount > balance.outstandingBalance;
  }

  /// Drives the asset row in the liability/lend asset selector so the selected
  /// asset can be brought into view.
  ScrollController get assetRowScrollController;

  void selectLiability(
    LiabilityBalanceEntity balance, {
    bool resetAmount = true,
    String? amount,
  });

  void setRepaymentMethod(String value);

  void setReminderBeforeDueDate(bool value);

  Future<void> pickFinalDueDate(BuildContext context);

  Future<void> pickInstallmentDueDate(BuildContext context, int index);

  void addInstallmentPeriod();

  void removeInstallmentPeriod(int index);

  void showKeypadForInstallment(BuildContext context, int index);

  @override
  void onInit() {
    super.onInit();
    // Keep the selected asset card visible when the selection changes (tap,
    // quick entry, direction switch).
    ever(selectedLiabilityId, (_) => revealSelectedAsset());
  }

  /// Centers the selected asset card in the asset row.
  void revealSelectedAsset() {
    final id = selectedLiabilityId.value;
    if (id == null || mergedItems.isEmpty) return;

    final index = mergedItems.indexWhere((b) => b.liability.id == id);
    if (index == -1) return;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => revealRowCard(
        scrollController: assetRowScrollController,
        index: index,
        itemWidth: assetCardWidth,
        itemGap: assetCardGap,
        leadingPadding: CcPaddingParams.PAGE_XS,
        tag: _debugTag,
      ),
    );
  }

  /// The asset row is empty until the user creates their first loan/record, so
  /// there is nothing a parsed quick entry could be saved into.
  @override
  bool get quickEntryHasSelectableCategory => mergedItems.isNotEmpty;

  /// A parsed category is only usable if the user already has a record in this
  /// tab carrying it. Validating against the seeded category list instead would
  /// accept any known category and report success even when the asset row can't
  /// hold the entry.
  @override
  List<String> get quickEntryAvailableCategoryIds => mergedItems
      .map((b) => b.liability.categoryId)
      .whereType<String>()
      .toSet()
      .toList();

  @override
  void applyQuickEntryCategory(String categoryId) {
    // 0. Save current parsed amount before selection resets it
    final currentParsedAmount = amountStr.value;

    // 1. Try to find an existing loan/record for this category
    final matchingItems = mergedItems
        .where((b) => b.liability.categoryId == categoryId)
        .toList();

    if (matchingItems.isNotEmpty) {
      // Pick the first one (most recently updated due to loadLiabilities sorting)
      final selected = matchingItems.first;

      '[AI_PARSING] 🎯 Matching existing liability found for category: $categoryId | amount: $currentParsedAmount'
          .Log(runtimeType.toString());

      // Pass the amount explicitly to avoid it being reset to '0' during selection
      selectLiability(
        selected,
        amount: currentParsedAmount != '0' ? currentParsedAmount : null,
      );

      pendingPrefillCategoryId.value = null;
      return;
    }

    // 2. Fallback: let the mixin handle setting pendingPrefillCategoryId
    // and resolving the CategoryEntity.
    super.applyQuickEntryCategory(categoryId);
  }

  void clearFormOnLogout() {
    mergedItems.clear();
    selectedLiabilityId.value = null;
    amountStr.value = '0';
    noteController.clear();
    showKeypad.value = false;
    selectedWalletId.value = null;
  }
}
