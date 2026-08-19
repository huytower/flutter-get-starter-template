import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../../category/data/datasources/local/category_seed.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/entities/wallet_entity.dart';
import 'wallet_controller.dart';

/// Backs [AddInvestmentSheet] — specifically for creating/editing investment assets.
@injectable
class AddInvestmentSheetController extends CcGetController {
  AddInvestmentSheetController(
    this._walletController,
    this._getCategories,
    this._getProfileSettings,
  );

  final WalletController _walletController;
  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;

  WalletEntity? _wallet;
  late final TextEditingController nameController;

  final RxString amountStr = '0'.obs;
  final RxBool showKeypad = false.obs;
  final GlobalKey amountFieldKey = GlobalKey();

  final RxList<CategoryEntity> investmentCategories = <CategoryEntity>[].obs;
  final Rxn<CategoryEntity> selectedInvestmentCategory = Rxn<CategoryEntity>();
  final RxBool isNameValid = false.obs;
  final RxnString nameError = RxnString();
  final RxBool isVip = false.obs;

  bool get isEditing => _wallet != null;

  /// Opening balance is locked once the asset has any transaction.
  bool get balanceLocked =>
      isEditing && _walletController.walletHasTransactions(_wallet!.id);

  void init(WalletEntity? wallet, {CategoryEntity? category}) {
    _wallet = wallet;
    nameController = TextEditingController(text: wallet?.name ?? '');
    nameController.addListener(_onNameChanged);
    _onNameChanged();

    if (isEditing) {
      amountStr.value = _walletController.bookBalanceOf(wallet!.id).toString();
    }

    _loadInvestmentCategories(preSelected: category);
    _loadVipStatus();
  }

  Future<void> _loadVipStatus() async {
    final settings = await _getProfileSettings();
    isVip.value = settings.isVip || CcFeatureFlags.isForceFullAccessEnabled;
  }

  Future<void> _loadInvestmentCategories({CategoryEntity? preSelected}) async {
    final result = await _getCategories.call();
    result.when((categories) {
      final enabledInvestment = categories
          .where((c) => c.type == CategoryType.investment && c.isEnabled)
          .toList();

      // Create index map to preserve seed order (mirroring CategorySettingsController)
      final seedIndexMap = <String, int>{};
      for (int i = 0; i < CategorySeed.categories.length; i++) {
        seedIndexMap[CategorySeed.categories[i].id] = i;
      }

      enabledInvestment.sort((a, b) {
        final indexA = seedIndexMap[a.id] ?? 999;
        final indexB = seedIndexMap[b.id] ?? 999;
        return indexA.compareTo(indexB);
      });

      investmentCategories.assignAll(enabledInvestment);

      if (preSelected != null) {
        selectInvestmentCategory(preSelected);
      } else if (_wallet?.categoryId != null) {
        selectedInvestmentCategory.value = enabledInvestment.firstWhereOrNull(
          (c) => c.id == _wallet!.categoryId,
        );
      }
    }, (_) {});
  }

  void _onNameChanged() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
    if (nameError.value != null) {
      nameError.value = null;
    }
  }

  void handleKeyPress(String key) {
    if (amountStr.value == '0') {
      if (key != '0' && key != '000') amountStr.value = key;
    } else {
      amountStr.value += key;
    }
  }

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

  void showKeypadAndScroll(BuildContext context) {
    FocusScope.of(context).unfocus();
    showKeypad.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = amountFieldKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void hideKeypad() => showKeypad.value = false;

  void selectInvestmentCategory(CategoryEntity category) {
    selectedInvestmentCategory.value = category;
    nameController.text = el.tr(category.nameKey);
  }

  Future<void> save(BuildContext context) async {
    final name = nameController.text.trim();
    final wallet = _wallet;

    // Check for duplicate names (excluding current wallet if editing)
    final isDuplicate = _walletController.wallets.any(
      (w) =>
          w.name.trim().toLowerCase() == name.toLowerCase() &&
          w.id != wallet?.id,
    );

    if (isDuplicate) {
      nameError.value = el.tr(CcLocaleKeys.wallet_name_duplicate_error);
      return;
    }

    if (wallet != null) {
      await _walletController.updateWallet(
        WalletEntity(
          id: wallet.id,
          name: name,
          balance: wallet.balance, // Preserve existing opening balance
          iconCode:
              selectedInvestmentCategory.value?.iconCode ?? wallet.iconCode,
          type: WalletType.investment,
          createdAt: wallet.createdAt,
          updatedAt: DateTime.now(),
          categoryId: selectedInvestmentCategory.value?.id ?? wallet.categoryId,
        ),
      );
    } else {
      await _walletController.addWallet(
        name: name,
        initialBalance: 0, // Default to 0 for new investments
        iconCode:
            selectedInvestmentCategory.value?.iconCode ??
            walletIconFor(WalletType.investment).codePoint,
        type: WalletType.investment,
        categoryId: selectedInvestmentCategory.value?.id,
      );
    }

    if (context.mounted) {
      // Refresh related controllers immediately to reflect memory changes
      _walletController.loadWallets();
      if (Get.isRegistered<BudgetAllocationController>()) {
        Get.find<BudgetAllocationController>().loadAll();
      }

      Navigator.pop(context);
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: isEditing
            ? el.tr(CcLocaleKeys.wallet_updated_success)
            : el.tr(CcLocaleKeys.wallet_added_success),
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
