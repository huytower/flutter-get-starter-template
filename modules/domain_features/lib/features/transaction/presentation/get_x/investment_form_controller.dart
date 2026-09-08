import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:collection/collection.dart' hide IterableFirstOrNull;
import 'package:domain_features/features/category/export_category.dart';
import 'package:domain_features/features/category/presentation/get_x/category_settings_controller.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/helper/merchant_match_helper.dart';
import '../../../../core/helper/quick_entry_intent_helper.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
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

  /// Pre-fills the investment asset selection from a resolved category id.
  /// If an existing investment wallet matches the category, it selects it.
  /// Otherwise, it selects the base category to prepare for adding a new asset.
  @override
  void applyQuickEntryCategory(String categoryId) {
    final text = quickEntryController.text.toLowerCase();

    // 1. Try to find an existing investment wallet for this category
    final matchingWallets = mergedItems
        .whereType<WalletEntity>()
        .where((w) => w.categoryId == categoryId)
        .toList();

    if (matchingWallets.isNotEmpty) {
      WalletEntity selected = matchingWallets.first;

      // If multiple wallets for this category, try to match by name in the text
      if (matchingWallets.length > 1) {
        for (final w in matchingWallets) {
          if (text.contains(w.name.toLowerCase())) {
            selected = w;
            break;
          }
        }
      }

      '[AI_PARSING] 🎯 Matching existing investment wallet found: ${selected.name}'
          .Log('InvestmentFormController');
      selectInvestmentWallet(selected);
      pendingPrefillCategoryId.value = null;
      return;
    }

    // 2. Fallback to selecting the base category
    final category = _cachedCategories.firstWhereOrNull(
      (c) => c.id == categoryId,
    );
    if (category != null) {
      '[AI_PARSING] 🎯 Matching investment category found: ${category.id}'.Log(
        'InvestmentFormController',
      );
      selectInvestmentCategory(category);
      pendingPrefillCategoryId.value = null;
    }
  }

  /// Investment now supports category pre-filling via [applyQuickEntryCategory].
  @override
  bool get quickEntryShowsCategoryInLabel => true;

  @override
  void applyQuickEntryIntent(QuickEntryIntent intent, String text) {
    if (intent != QuickEntryIntent.investment) return;

    setDirection(
      QuickEntryIntentHelper.isInvestmentReturn(text)
          ? InvestmentDirection.returnProfit
          : InvestmentDirection.contribute,
    );
  }

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

  @override
  List<String> get quickEntryAvailableCategoryIds {
    // In Investment, a category is only "available" for quick selection
    // if the user has already created an investment item (Wallet) for it.
    final List<String> ids = mergedItems
        .whereType<WalletEntity>()
        .map((wallet) => wallet.categoryId)
        .whereType<String>()
        .toList();

    return ids;
  }

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

    if (amount == '0' || amount.isEmpty) {
      return false;
    }
    if (walletId == null) {
      return false;
    }
    if (adding) {
      final ok = category != null && newItemName.value.trim().isNotEmpty;
      return ok;
    }
    if (invWalletId == null) {
      return false;
    }
    if (category != null) {
      return true;
    }
    if (wallet?.categoryId != null) {
      return true;
    }
    final investmentCats = _cachedCategories
        .where((c) => c.type == CategoryType.investment)
        .toList();
    final singleCat = investmentCats.length == 1;
    return singleCat;
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
    final parentController = Get.find<TransactionController>();
    ever(parentController.wallets, (_) {
      _recomputeMergedItems();
    });

    ever(CategorySettingsController.onCategoriesChanged, (_) {
      _loadCategories();
      _recomputeMergedItems();
    });
    initQuickEntry();
  }

  Future<void> _loadAll() async {
    isLoadingMerged.value = true;
    final settings = await _getProfileSettings();
    isVip.value = settings.isVip;
    await _loadCategories();
    await _recomputeMergedItems();
    isLoadingMerged.value = false;
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories();
    result.when((categories) {
      _cachedCategories.assignAll(categories);
    }, (error) {});
  }

  /// Refreshes the list of investment assets.
  /// Only shows existing investment wallets (synchronized with investment_list_page),
  /// not base categories from category_settings_page.
  Future<void> _recomputeMergedItems() async {
    final parentWallets = Get.find<TransactionController>().wallets;
    final assets = parentWallets
        .where((w) => w.type == WalletType.investment)
        .toList();

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

    if (selectedInvestmentWalletId.value == null &&
        selectedCategory.value == null &&
        mergedItems.isNotEmpty) {
      final first = mergedItems.first;
      if (first is WalletEntity) {
        selectInvestmentWallet(first);
      }
    } else if (selectedInvestmentWalletId.value != null &&
        selectedCategory.value == null) {
      final wallet = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
        (w) => w.id == selectedInvestmentWalletId.value,
      );
      if (wallet != null) {
        selectInvestmentWallet(wallet);
      } else {}
    }
  }

  void selectInvestmentWallet(WalletEntity wallet) {
    selectedInvestmentWalletId.value = wallet.id;
    isAddingNewItem.value = false;

    final categories = _cachedCategories.toList();
    CategoryEntity? matched;
    if (wallet.categoryId != null) {
      matched = categories.firstWhereOrNull((c) => c.id == wallet.categoryId);
    }

    if (matched == null) {
      final investmentCats = categories
          .where((c) => c.type == CategoryType.investment)
          .toList();
      if (investmentCats.length == 1) {
        matched = investmentCats.first;
      }
    }

    if (matched != null) {
      selectedCategory.value = matched;
    } else {}
  }

  @override
  void selectInvestmentCategory(CategoryEntity category) {
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

  @override
  void onClose() {
    newItemNameController.dispose();
    disposeQuickEntry();
    super.onClose();
  }

  void setDirection(InvestmentDirection value) {
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
          selectInvestmentWallet(firstAsset);
        } else {}
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

  @override
  void clearCategorySelection() {
    selectedCategory.value = null;
    selectedInvestmentWalletId.value = null;
    isAddingNewItem.value = false;
  }

  void setNewItemName(String value) {
    newItemName.value = value;
  }

  @override
  String? composeNote() {
    final userNote = super.composeNote();
    final subsegment = direction.value == InvestmentDirection.contribute
        ? el.tr(CcLocaleKeys.transaction_investment_contribution)
        : el.tr(CcLocaleKeys.transaction_investment_return);

    if (userNote == null || userNote.isEmpty) return subsegment;
    return '$subsegment · $userNote';
  }

  @override
  void onReset() {
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
    if (isSubmitting.value || !canSubmit) {
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
      isSubmitting.value = false;
      if (context.mounted) {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.transaction_validation_category_required),
        );
      }
      return;
    }

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
      (investmentWallet) async {
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
        await refreshParent();

        // Complete the investment guideline task
        if (Get.isRegistered<GuidelineController>()) {
          Get.find<GuidelineController>().completeTask('investment');
        }
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
