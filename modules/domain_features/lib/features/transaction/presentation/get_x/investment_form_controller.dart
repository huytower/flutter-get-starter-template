import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/usecases/create_investment_transaction_usecase.dart';
import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

@injectable
class InvestmentFormController extends TransactionFormController {
  final Rx<InvestmentDirection> direction = InvestmentDirection.contribute.obs;
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final RxInt categoryKey = 0.obs;

  /// Existing investment positions (`WalletType.investment`) under the
  /// selected category, derived from the parent's raw (unfiltered) wallets.
  final RxList<WalletEntity> investmentItems = <WalletEntity>[].obs;
  final Rx<String?> selectedInvestmentWalletId = Rx<String?>(null);

  final RxBool isAddingNewItem = false.obs;
  final TextEditingController newItemNameController = TextEditingController();
  final RxString newItemName = ''.obs;

  /// Free-tier gate: non-VIP users can only attach Chi ra to the selected
  /// category itself (a single auto-named item, see
  /// [_recomputeInvestmentItems]) — only VIP unlocks typing a custom item
  /// name. Defaults to `false` (the safe/conservative UI) until
  /// [_loadVipStatus] resolves.
  final RxBool isVip = false.obs;

  @override
  bool get canSubmit {
    if (selectedCategory.value == null) return false;
    if (amountStr.value == '0' || amountStr.value.isEmpty) return false;
    // Both directions touch a real wallet now — Chi ra debits it, Thu vào
    // credits it — so both need one picked.
    if (selectedWalletId.value == null) return false;
    if (isAddingNewItem.value) {
      return newItemName.value.trim().isNotEmpty;
    }
    return selectedInvestmentWalletId.value != null;
  }

  @override
  void onInit() {
    super.onInit();
    final parentController = Get.find<TransactionController>();
    _recomputeInvestmentItems(parentController.wallets);
    ever(parentController.wallets, _recomputeInvestmentItems);
    _loadVipStatus();
  }

  /// Defaults to non-VIP (see [isVip]) so a slow load never briefly unlocks
  /// custom naming; only flips + corrects state once confirmed VIP.
  Future<void> _loadVipStatus() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    if (!settings.isVip) return;
    isVip.value = true;
    if (isAddingNewItem.value) cancelAddingNewItem();
    _recomputeInvestmentItems(Get.find<TransactionController>().wallets);
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
      cancelAddingNewItem();
    }
    // Re-evaluate free-tier auto-naming (only applies to Chi ra) now that
    // the direction changed.
    _recomputeInvestmentItems(Get.find<TransactionController>().wallets);
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    selectedInvestmentWalletId.value = null;
    cancelAddingNewItem();
    _recomputeInvestmentItems(Get.find<TransactionController>().wallets);
  }

  void selectInvestmentItem(String walletId) {
    selectedInvestmentWalletId.value = walletId;
    isAddingNewItem.value = false;
  }

  void startAddingNewItem() {
    if (!isVip.value) return;
    isAddingNewItem.value = true;
    selectedInvestmentWalletId.value = null;
  }

  void cancelAddingNewItem() {
    isAddingNewItem.value = false;
    newItemNameController.clear();
    newItemName.value = '';
  }

  void setNewItemName(String value) {
    newItemName.value = value;
  }

  /// Filters the parent's wallets down to the selected category's investment
  /// positions and, if nothing valid is currently picked, auto-selects the
  /// first one — mirrors [CategorySelectionSection]'s `autoSelectFirst`, and
  /// applies the same way whether the tab is showing Chi ra or Thu vào. Runs
  /// on init, on category switch, and whenever the parent's wallet list
  /// changes (e.g. right after a new item is created).
  void _recomputeInvestmentItems(List<WalletEntity> parentWallets) {
    final categoryId = selectedCategory.value?.id;
    if (categoryId == null) {
      investmentItems.clear();
      selectedInvestmentWalletId.value = null;
      return;
    }

    final items = parentWallets
        .where(
          (w) => w.type == WalletType.investment && w.categoryId == categoryId,
        )
        .toList();
    investmentItems.assignAll(items);

    // Free tier: no existing item under this category to attach Chi ra to —
    // silently attach to a single auto-named item (the category's own
    // label) instead of offering custom naming.
    if (!isVip.value &&
        items.isEmpty &&
        direction.value == InvestmentDirection.contribute) {
      isAddingNewItem.value = true;
      newItemName.value = el.tr(selectedCategory.value!.nameKey);
      return;
    }

    if (isAddingNewItem.value) return;
    final stillValid = items.any(
      (w) => w.id == selectedInvestmentWalletId.value,
    );
    if (!stillValid) {
      selectedInvestmentWalletId.value = items.isNotEmpty
          ? items.first.id
          : null;
    }
  }

  @override
  void onReset() {
    // Stay on whichever tab (Chi ra/Thu vào) was just used — don't jump back
    // to Chi ra after a Thu vào submission.
    selectedCategory.value = null;
    categoryKey.value++;
    selectedInvestmentWalletId.value = null;
    cancelAddingNewItem();
    investmentItems.clear();
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

    final result = await getIt<CreateInvestmentTransactionUseCase>().call(
      params,
    );
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
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
