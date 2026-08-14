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
import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

@injectable
class InvestmentFormController extends TransactionFormController {
  InvestmentFormController(
    this._getCategories,
    this._getProfileSettings,
    this._createInvestmentTransaction,
  );

  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CreateInvestmentTransactionUseCase _createInvestmentTransaction;

  final Rx<InvestmentDirection> direction = InvestmentDirection.contribute.obs;
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final RxInt categoryKey = 0.obs;

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
    if (selectedCategory.value == null) return false;
    if (amountStr.value == '0' || amountStr.value.isEmpty) return false;
    if (selectedWalletId.value == null) return false;
    if (isAddingNewItem.value) {
      return newItemName.value.trim().isNotEmpty;
    }
    return selectedInvestmentWalletId.value != null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
    final parentController = Get.find<TransactionController>();
    ever(parentController.wallets, (_) => _recomputeMergedItems());

    // Listen to global category changes (e.g. from Settings)
    ever(
      CategorySettingsController.onCategoriesChanged,
      (_) => _recomputeMergedItems(),
    );
  }

  Future<void> _loadAll() async {
    isLoadingMerged.value = true;
    await _loadVipStatus();
    await _recomputeMergedItems();
    isLoadingMerged.value = false;
  }

  /// Refreshes the merged list of investment categories and existing assets.
  /// Assets have high priority and appear first, matching Dashboard order.
  Future<void> _recomputeMergedItems() async {
    final catResult = await _getCategories();
    final List<CategoryEntity> allCategories = catResult.when(
      (c) => c
          .where((e) => e.isEnabled && e.type == CategoryType.investment)
          .toList(),
      (_) => [],
    );

    // Create index map to preserve seed order
    final seedIndexMap = <String, int>{};
    for (int i = 0; i < CategorySeed.categories.length; i++) {
      seedIndexMap[CategorySeed.categories[i].id] = i;
    }

    allCategories.sort((a, b) {
      final indexA = seedIndexMap[a.id] ?? 999;
      final indexB = seedIndexMap[b.id] ?? 999;
      return indexA.compareTo(indexB);
    });

    final parentWallets = Get.find<TransactionController>().wallets;
    final assets = parentWallets
        .where((w) => w.type == WalletType.investment)
        .toList();

    // High Priority Sorting: Match Dashboard (DisplayOrder) + Recency (UpdatedAt)
    assets.sort((a, b) {
      if (a.displayOrder != b.displayOrder) {
        return a.displayOrder.compareTo(b.displayOrder);
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    mergedItems.assignAll([...assets, ...allCategories]);

    // Auto-select first if nothing selected
    if (selectedCategory.value == null && mergedItems.isNotEmpty) {
      final first = mergedItems.first;
      if (first is WalletEntity) {
        selectAsset(first);
      } else if (first is CategoryEntity) {
        selectCategory(first);
      }
    }
  }

  void selectAsset(WalletEntity wallet) {
    selectedInvestmentWalletId.value = wallet.id;
    isAddingNewItem.value = false;

    // Resolve parent category
    final parentCat = mergedItems.whereType<CategoryEntity>().firstWhereOrNull(
      (c) => c.id == wallet.categoryId,
    );

    if (parentCat != null) {
      selectedCategory.value = parentCat;
    }
  }

  @override
  void selectCategory(CategoryEntity category) {
    selectedCategory.value = category;
    selectedInvestmentWalletId.value = null;

    if (isVip.value) {
      isAddingNewItem.value = true;
      newItemName.value = '';
      newItemNameController.clear();
    } else {
      // Free tier: attach to category name
      isAddingNewItem.value = true;
      newItemName.value = el.tr(category.nameKey);
    }
  }

  Future<void> _loadVipStatus() async {
    final settings = await _getProfileSettings();
    isVip.value = settings.isVip || CcFeatureFlags.isForceFullAccessEnabled;
  }

  @override
  void onClose() {
    newItemNameController.dispose();
    super.onClose();
  }

  void setDirection(InvestmentDirection value) {
    if (direction.value == value) return;
    direction.value = value;
    if (value == InvestmentDirection.returnProfit) {
      // Logic for return profit: must pick existing asset if available
      if (isAddingNewItem.value || selectedInvestmentWalletId.value == null) {
        final firstAsset = mergedItems
            .whereType<WalletEntity>()
            .firstWhereOrNull((_) => true);
        if (firstAsset != null) {
          selectAsset(firstAsset);
        }
      }
    }
  }

  void setCategory(CategoryEntity category) {
    selectCategory(category);
  }

  void selectInvestmentItem(String walletId) {
    final asset = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
      (w) => w.id == walletId,
    );
    if (asset != null) selectAsset(asset);
  }

  void setNewItemName(String value) {
    newItemName.value = value;
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
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final category = selectedCategory.value!;
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
