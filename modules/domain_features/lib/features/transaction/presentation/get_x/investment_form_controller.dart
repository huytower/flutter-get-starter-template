import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:collection/collection.dart' hide IterableFirstOrNull;
import 'package:domain_features/features/category/export_category.dart';
import 'package:domain_features/features/category/presentation/get_x/category_settings_controller.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/usecases/create_investment_transaction_usecase.dart';
import 'quick_entry_mixin.dart';
import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

@injectable
class InvestmentFormController extends TransactionFormController
    with QuickEntryMixin {
  InvestmentFormController(
    this._getCategories,
    this._getProfileSettings,
    this._createInvestmentTransaction,
  );

  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CreateInvestmentTransactionUseCase _createInvestmentTransaction;

  @override
  String get quickEntryCategoryType => CategoryType.investment;

  /// Investment has no category-picker UI of its own (category is derived
  /// from the chosen investment asset, which stays a manual pick) — so
  /// there's nothing for a quick-entry categoryId to prefill. Overridden as
  /// a no-op rather than wiring up an inert `pendingPrefillCategoryId`.
  @override
  void applyQuickEntryCategory(String categoryId) {}

  /// Since [applyQuickEntryCategory] is a no-op, showing a resolved
  /// category in the suggestion chip would be misleading — it'd look like
  /// tapping "Apply" selects that category when it silently won't.
  @override
  bool get quickEntryShowsCategoryInLabel => false;

  /// Unused by [applyQuickEntryCategory] (a no-op here), but still required
  /// to satisfy [QuickEntryMixin]'s contract.
  @override
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  final Rx<InvestmentDirection> direction = InvestmentDirection.contribute.obs;
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  @override
  final RxInt categoryKey = 0.obs;
  final RxList<CategoryEntity> _cachedCategories = <CategoryEntity>[].obs;

  /// Merged list of existing investment assets (`WalletEntity`) and
  /// base investment categories (`CategoryEntity`).
  final RxList<dynamic> mergedItems = <dynamic>[].obs;
  final RxBool isLoadingMerged = true.obs;

  final Rx<String?> selectedInvestmentWalletId = Rx<String?>(null);

  final RxBool isAddingNewItem = false.obs;
  final TextEditingController newItemNameController = TextEditingController();
  final RxString newItemName = ''.obs;

  /// Free-tier gate: non-VIP users can only attach Chi ra to the selected
  /// category itself (a single auto-named item) — only VIP unlocks typing a
  /// custom item name.
  final RxBool isVip = false.obs;

  @override
  bool get canSubmit {
    final amount = amountStr.value;
    final walletId = selectedWalletId.value;
    final adding = isAddingNewItem.value;
    final invWalletId = selectedInvestmentWalletId.value;
    final category = selectedCategory.value;
    final wallet = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
      (w) => w.id == invWalletId,
    );

    debugPrint('[INV_FORM] canSubmit: amount=$amount, walletId=$walletId, adding=$adding, '
        'invWalletId=$invWalletId, category=${category?.id}, walletCategoryId=${wallet?.categoryId}, '
        'cachedCats=${_cachedCategories.length}');

    if (amount == '0' || amount.isEmpty) {
      debugPrint('[INV_FORM] canSubmit: BLOCKED amount');
      return false;
    }
    if (walletId == null) {
      debugPrint('[INV_FORM] canSubmit: BLOCKED walletId');
      return false;
    }
    if (adding) {
      final ok = category != null && newItemName.value.trim().isNotEmpty;
      debugPrint('[INV_FORM] canSubmit: adding ok=$ok');
      return ok;
    }
    if (invWalletId == null) {
      debugPrint('[INV_FORM] canSubmit: BLOCKED invWalletId');
      return false;
    }
    if (category != null) {
      debugPrint('[INV_FORM] canSubmit: PASS category already set');
      return true;
    }
    if (wallet?.categoryId != null) {
      debugPrint('[INV_FORM] canSubmit: PASS wallet.categoryId');
      return true;
    }
    final investmentCats = _cachedCategories
        .where((c) => c.type == CategoryType.investment)
        .toList();
    final singleCat = investmentCats.length == 1;
    debugPrint('[INV_FORM] canSubmit: BLOCKED no category. investmentCats=${investmentCats.length}, singleCat=$singleCat');
    return singleCat;
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('[INV_FORM] onInit');
    _loadAll();
    final parentController = Get.find<TransactionController>();
    ever(parentController.wallets, (_) {
      debugPrint('[INV_FORM] parent wallets changed, recomputing');
      _recomputeMergedItems();
    });

    ever(
      CategorySettingsController.onCategoriesChanged,
      (_) {
        debugPrint('[INV_FORM] categories changed, reloading');
        _loadCategories();
        _recomputeMergedItems();
      },
    );
    initQuickEntry();
  }

  Future<void> _loadAll() async {
    debugPrint('[INV_FORM] _loadAll start');
    isLoadingMerged.value = true;
    await _loadVipStatus();
    await _loadCategories();
    debugPrint('[INV_FORM] _loadAll categories loaded: ${_cachedCategories.length}');
    await _recomputeMergedItems();
    debugPrint('[INV_FORM] _loadAll mergedItems=${mergedItems.length}, selectedCategory=${selectedCategory.value?.id}, selectedInvWallet=${selectedInvestmentWalletId.value}');
    isLoadingMerged.value = false;
  }

  Future<void> _loadCategories() async {
    debugPrint('[INV_FORM] _loadCategories start');
    final result = await _getCategories();
    result.when(
      (categories) {
        debugPrint('[INV_FORM] _loadCategories success: ${categories.length} cats, ids=${categories.map((c) => c.id).toList()}');
        _cachedCategories.assignAll(categories);
      },
      (error) {
        debugPrint('[INV_FORM] _loadCategories FAILED: ${error.message}');
      },
    );
  }

  /// Refreshes the list of investment assets.
  /// Only shows existing investment wallets (synchronized with investment_list_page),
  /// not base categories from category_settings_page.
  Future<void> _recomputeMergedItems() async {
    final parentWallets = Get.find<TransactionController>().wallets;
    final assets = parentWallets
        .where((w) => w.type == WalletType.investment)
        .toList();
    debugPrint('[INV_FORM] _recomputeMergedItems: parentWallets=${parentWallets.length}, investmentAssets=${assets.length}');

    assets.sort((a, b) {
      if (a.displayOrder != b.displayOrder) {
        return a.displayOrder.compareTo(b.displayOrder);
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    // Only include investment wallets, not base categories
    // This ensures consistency with investment_list_page
    final List<dynamic> items = [...assets];
    mergedItems.assignAll(items);
    debugPrint('[INV_FORM] _recomputeMergedItems: mergedItems count=${mergedItems.length} (wallets only)');

    if (selectedInvestmentWalletId.value == null &&
        selectedCategory.value == null &&
        mergedItems.isNotEmpty) {
      final first = mergedItems.first;
      if (first is WalletEntity) {
        debugPrint('[INV_FORM] _recomputeMergedItems: auto-selecting first wallet ${first.id}, categoryId=${first.categoryId}');
        selectInvestmentWallet(first);
      }
    } else if (selectedInvestmentWalletId.value != null &&
        selectedCategory.value == null) {
      debugPrint('[INV_FORM] _recomputeMergedItems: re-resolving selected wallet');
      final wallet = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
        (w) => w.id == selectedInvestmentWalletId.value,
      );
      if (wallet != null) {
        selectInvestmentWallet(wallet);
      } else {
        debugPrint('[INV_FORM] _recomputeMergedItems: selected wallet NOT FOUND in mergedItems');
      }
    }
  }

  void selectInvestmentWallet(WalletEntity wallet) {
    debugPrint('[INV_FORM] selectInvestmentWallet: wallet=${wallet.id}, categoryId=${wallet.categoryId}');
    selectedInvestmentWalletId.value = wallet.id;
    isAddingNewItem.value = false;

    final categories = _cachedCategories.toList();
    CategoryEntity? matched;
    if (wallet.categoryId != null) {
      matched = categories.firstWhereOrNull(
        (c) => c.id == wallet.categoryId,
      );
      debugPrint('[INV_FORM] selectInvestmentWallet: matched by wallet.categoryId=${matched?.id}');
    }

    if (matched == null) {
      final investmentCats = categories
          .where((c) => c.type == CategoryType.investment)
          .toList();
      debugPrint('[INV_FORM] selectInvestmentWallet: no direct match. investmentCats=${investmentCats.length}');
      if (investmentCats.length == 1) {
        matched = investmentCats.first;
        debugPrint('[INV_FORM] selectInvestmentWallet: auto-selected single investment cat=${matched.id}');
      }
    }

    if (matched != null) {
      selectedCategory.value = matched;
      debugPrint('[INV_FORM] selectInvestmentWallet: selectedCategory SET to ${matched.id}');
    } else {
      debugPrint('[INV_FORM] selectInvestmentWallet: selectedCategory REMAINS null');
    }
  }

  @override
  void selectInvestmentCategory(CategoryEntity category) {
    debugPrint('[INV_FORM] selectInvestmentCategory: id=${category.id}, name=${category.nameKey}');
    selectedCategory.value = category;
    selectedInvestmentWalletId.value = null;

    if (isVip.value) {
      isAddingNewItem.value = true;
      newItemName.value = el.tr(category.nameKey);
      newItemNameController.text = newItemName.value;
    } else {
      isAddingNewItem.value = true;
      newItemName.value = el.tr(category.nameKey);
      newItemNameController.text = newItemName.value;
    }
  }

  Future<void> _loadVipStatus() async {
    final settings = await _getProfileSettings();
    isVip.value = settings.isVip || CcFeatureFlags.isForceFullAccessEnabled;
  }

  @override
  void onClose() {
    newItemNameController.dispose();
    disposeQuickEntry();
    super.onClose();
  }

  void setDirection(InvestmentDirection value) {
    debugPrint('[INV_FORM] setDirection: $value (current=${direction.value})');
    if (direction.value == value) return;
    direction.value = value;
    _recomputeMergedItems();
    if (value == InvestmentDirection.returnProfit) {
      // Logic for return profit: must pick existing asset if available
      if (isAddingNewItem.value || selectedInvestmentWalletId.value == null) {
        final firstAsset = mergedItems
            .whereType<WalletEntity>()
            .firstWhereOrNull((_) => true);
        if (firstAsset != null) {
          debugPrint('[INV_FORM] setDirection: auto-selecting first asset for returnProfit');
          selectInvestmentWallet(firstAsset);
        } else {
          debugPrint('[INV_FORM] setDirection: no asset to auto-select for returnProfit');
        }
      }
    }
  }

  void setCategory(CategoryEntity category) {
    selectInvestmentCategory(category);
  }

  void selectInvestmentItem(String walletId) {
    final asset = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
      (w) => w.id == walletId,
    );
    if (asset != null) selectInvestmentWallet(asset);
  }

  void setNewItemName(String value) {
    newItemName.value = value;
  }

  @override
  void onReset() {
    debugPrint('[INV_FORM] onReset');
    selectedCategory.value = null;
    categoryKey.value++;
    selectedInvestmentWalletId.value = null;
    isAddingNewItem.value = false;
    newItemName.value = '';
    newItemNameController.clear();
    _recomputeMergedItems();
    resetQuickEntry();
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    debugPrint('[INV_FORM] submitForm called, canSubmit=$canSubmit, isSubmitting=$isSubmitting');
    if (isSubmitting.value || !canSubmit) {
      debugPrint('[INV_FORM] submitForm BLOCKED by guard');
      return;
    }
    isSubmitting.value = true;

    CategoryEntity? category = selectedCategory.value;
    if (category == null && selectedInvestmentWalletId.value != null) {
      final wallet = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
        (w) => w.id == selectedInvestmentWalletId.value,
      );
      if (wallet != null && wallet.categoryId != null) {
        final catResult = await _getCategories();
        category = catResult.tryGetSuccess()?.firstWhereOrNull(
          (c) => c.id == wallet.categoryId,
        );
      }
    }

    if (category == null) {
      debugPrint('[INV_FORM] submitForm: category is NULL after fallback resolution');
      isSubmitting.value = false;
      if (context.mounted) {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.transaction_validation_category_required),
        );
      }
      return;
    }
    debugPrint('[INV_FORM] submitForm: category resolved to ${category.id}, proceeding');

    final params = CreateInvestmentTransactionParams(
      direction: direction.value,
      liquidWalletId: selectedWalletId.value,
      investmentWalletId: isAddingNewItem.value
          ? null
          : selectedInvestmentWalletId.value,
      newItemName: isAddingNewItem.value ? newItemName.value.trim() : null,
      categoryId: category.id,
      categoryLabel: el.tr(category.nameKey),
      categoryIconCode: category.iconCode,
      categoryIconFamily: category.iconFamily,
      amount: int.tryParse(amountStr.value) ?? 0,
      note: composeNote(),
      date: date.value,
    );

    final result = await _createInvestmentTransaction.call(params);
    isSubmitting.value = false;

    result.when(
      (investmentWallet) {
        final parentController = Get.find<TransactionController>();
        if (!parentController.wallets.any((w) => w.id == investmentWallet.id)) {
          parentController.wallets.add(investmentWallet);
        }

        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_investment_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        resetForm();
        refreshParent();

        // Update real-time amount values in the Investment section of Budget Allocation
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().loadWallets();
        }
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
