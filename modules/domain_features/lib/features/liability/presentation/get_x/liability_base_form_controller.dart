import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../transaction/presentation/get_x/quick_entry_mixin.dart';
import '../../../transaction/presentation/get_x/transaction_form_controller.dart';
import '../../../transaction/presentation/helper/horizontal_row_reveal.dart';
import '../../domain/entities/liability_balance_entity.dart';
import 'liability_installment_draft.dart';

enum LiabilityDirectionForm { increase, decrease }

const String _debugTag = 'LiabilityAssetRow';

abstract class LiabilityBaseFormController extends TransactionFormController
    with QuickEntryMixin {
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

    'liabilityReveal | index=$index id=$id'.Log(_debugTag);

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
}
