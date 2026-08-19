import 'package:cc_micro_features/features/web/export_web.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/emergency_fund_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../profile/domain/usecases/update_profile_settings_usecase.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import 'wallet_controller.dart';

/// Backs [AddLiquidSheet] — create/edit form state for a single liquid wallet.
/// Instantiated fresh per sheet open via [init]; see the sheet's
/// `GetX` wrapper for the lifecycle.
@injectable
class AddLiquidSheetController extends CcGetController {
  AddLiquidSheetController(
    this._walletController,
    this._getCategories,
    this.userLevel,
  );

  final WalletController _walletController;
  final GetCategoriesUseCase _getCategories;
  final UserLevelController userLevel;

  WalletEntity? _wallet;
  late final TextEditingController nameController;

  final RxString amountStr = '0'.obs;
  final RxBool showKeypad = false.obs;
  final GlobalKey amountFieldKey = GlobalKey();

  final RxString newType = WalletType.bank.obs;

  final RxList<CategoryEntity> investmentCategories = <CategoryEntity>[].obs;
  final Rxn<CategoryEntity> selectedInvestmentCategory = Rxn<CategoryEntity>();

  final RxBool emergencyFundUnlocked = false.obs;
  final RxBool showEmergencyFundLockedHint = false.obs;
  final RxBool isNameValid = false.obs;
  final RxBool isSubmitting = false.obs;

  bool get isEditing => _wallet != null;

  bool get isCash => _wallet?.type == WalletType.cash;

  bool get balanceLocked =>
      isEditing && _walletController.walletHasTransactions(_wallet!.id);

  void init(WalletEntity? wallet) {
    _wallet = wallet;
    nameController = TextEditingController(text: wallet?.name ?? '');
    nameController.addListener(_onNameChanged);
    _onNameChanged();
    if (isEditing) {
      amountStr.value = _walletController.bookBalanceOf(wallet!.id).toString();
      newType.value = wallet.type;
    }
    _loadEmergencyFundGate();
    _loadInvestmentCategories();
  }

  Future<void> _loadInvestmentCategories() async {
    final result = await _getCategories.call();
    result.when((categories) {
      final enabledInvestment = categories
          .where((c) => c.type == CategoryType.investment && c.isEnabled)
          .toList();
      investmentCategories.assignAll(enabledInvestment);

      if (_wallet?.categoryId != null) {
        selectedInvestmentCategory.value = enabledInvestment.firstWhereOrNull(
          (c) => c.id == _wallet!.categoryId,
        );
      }
    }, (_) {});
  }

  void _onNameChanged() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  Future<void> _loadEmergencyFundGate() async {
    final level = getIt<UserLevelController>().status.value.level;
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    emergencyFundUnlocked.value =
        CcFeatureFlags.isForceFullAccessEnabled ||
        (level >= 2 && settings.hasViewedEmergencyFundEbook);
  }

  Future<void> openEmergencyFundEbook(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebPage(
          url: emergencyFundEbookUrl,
          title: el.tr(CcLocaleKeys.wallet_emergency_fund),
        ),
      ),
    );
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    await getIt<UpdateProfileSettingsUseCase>().call(
      settings.copyWith(hasViewedEmergencyFundEbook: true),
    );
    await _loadEmergencyFundGate();
    if (emergencyFundUnlocked.value) {
      newType.value = WalletType.emergencyFund;
      showEmergencyFundLockedHint.value = false;
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

  void selectType(String type) {
    if (type == WalletType.emergencyFund && !emergencyFundUnlocked.value) {
      showEmergencyFundLockedHint.value = true;
      return;
    }
    newType.value = type;
    showEmergencyFundLockedHint.value = false;

    if (type != WalletType.investment) {
      selectedInvestmentCategory.value = null;
    }
  }

  void selectInvestmentCategory(CategoryEntity category) {
    selectedInvestmentCategory.value = category;
    if (nameController.text.trim().isEmpty) {
      nameController.text = el.tr(category.nameKey);
    }
  }

  Future<void> save(BuildContext context) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    final name = nameController.text.trim();
    final balance = int.tryParse(amountStr.value) ?? 0;
    final wallet = _wallet;

    try {
      if (wallet != null) {
        await _walletController.updateWallet(
          WalletEntity(
            id: wallet.id,
            name: name,
            balance: balance,
            iconCode:
                newType.value == WalletType.investment &&
                    selectedInvestmentCategory.value != null
                ? selectedInvestmentCategory.value!.iconCode
                : wallet.iconCode,
            type: wallet.type,
            createdAt: wallet.createdAt,
            updatedAt: DateTime.now(),
            categoryId: newType.value == WalletType.investment
                ? selectedInvestmentCategory.value?.id
                : wallet.categoryId,
          ),
        );
      } else {
        await _walletController.addWallet(
          name: name,
          initialBalance: balance,
          iconCode:
              newType.value == WalletType.investment &&
                  selectedInvestmentCategory.value != null
              ? selectedInvestmentCategory.value!.iconCode
              : walletIconFor(newType.value).codePoint,
          type: newType.value,
          categoryId: newType.value == WalletType.investment
              ? selectedInvestmentCategory.value?.id
              : null,
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
    } catch (e) {
      if (context.mounted) {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.app_error_general),
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
