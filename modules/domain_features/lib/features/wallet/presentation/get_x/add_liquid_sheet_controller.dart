import 'package:cc_micro_features/features/web/export_web.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/constant/emergency_fund_constants.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/get_x/prj_get_controller.dart';
import 'package:domain_features/core/presentation/helper/wallet_icon_helper.dart';
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/wallet/domain/services/emergency_fund_access.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';

import 'wallet_change_effects.dart';
import 'wallet_controller.dart';

/// Backs [AddLiquidSheet] — create/edit form state for a single liquid wallet.
/// Instantiated fresh per sheet open via [init]; see the sheet's
/// `GetX` wrapper for the lifecycle.
@injectable
class AddLiquidSheetController extends PrjGetController {
  AddLiquidSheetController(
    this._walletController,
    this._getCategories,
    this._getSettings,
    this._emergencyFund,
    this._effects,
  );

  final WalletController _walletController;
  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getSettings;
  final EmergencyFundAccess _emergencyFund;
  final WalletChangeEffects _effects;

  /// The onboarding guideline, for the sheet's badges.
  GuidelineProvider get guideline => _effects.guideline;

  /// Whether the emergency-fund type is shown at all.
  bool get hasEmergencyFundOffered => _emergencyFund.hasOffered;

  WalletEntity? _wallet;
  final TextEditingController nameController = TextEditingController();

  final RxString amountStr = '0'.obs;
  final RxBool showKeypad = false.obs;
  final GlobalKey amountFieldKey = GlobalKey();

  final RxString newType = WalletType.bank.obs;

  final RxList<CategoryEntity> investmentCategories = <CategoryEntity>[].obs;
  final Rxn<CategoryEntity> selectedInvestmentCategory = Rxn<CategoryEntity>();

  final RxBool emergencyFundUnlocked = false.obs;
  final RxBool showEmergencyFundLockedHint = false.obs;
  final RxBool hasNameValid = false.obs;
  final RxBool hasAmountValid = false.obs;
  final RxnString nameError = RxnString();
  final RxBool hasSubmitting = false.obs;
  final RxString currencyCode = CurrencyConstants.defaultCurrencyCode.obs;

  bool get hasEditing => _wallet != null;

  bool get hasCash => _wallet?.type == WalletType.cash;

  /// The built-in Cash and default Bank wallets keep a fixed, localized name:
  /// they are stored with an empty name and labelled at display time, so the
  /// name must not be edited (or overwritten with the translated label).
  bool get hasNameLocked =>
      hasEditing && !_walletController.canDeleteWallet(_wallet!);

  bool get balanceLocked =>
      hasEditing && _walletController.walletHasTransactions(_wallet!.id);

  /// The name to prefill when editing [wallet].
  ///
  /// The default Cash and Bank wallets are stored with an EMPTY name and are
  /// localized only at display time (see `WalletDisplayName`). Prefilling the
  /// stored value left the field blank, which also kept Save disabled because an
  /// empty name is invalid. Show the same label the wallet list shows instead.
  String _initialName(WalletEntity? wallet) {
    if (wallet == null) return '';
    if (wallet.type == WalletType.cash) return el.tr(PrjLocaleKeys.wallet_cash);
    final stored = wallet.name.trim();
    if (stored.isNotEmpty) return wallet.name;
    if (wallet.type == WalletType.bank) return el.tr(PrjLocaleKeys.wallet_bank);
    return '';
  }

  void prepareForm(WalletEntity? wallet) {
    _wallet = wallet;
    nameController.text = _initialName(wallet);
    nameController.removeListener(_onNameChanged);
    nameController.addListener(_onNameChanged);
    _onNameChanged();
    if (hasEditing) {
      amountStr.value = _walletController
          .displayBookBalanceOf(wallet!.id)
          .toString();
      newType.value = wallet.type;
    }
    amountStr.listen((_) => _validateAmount());
    _validateAmount();
    _loadAsyncData();
  }

  Future<void> _loadAsyncData() async {
    final settings = await _getSettings();
    currencyCode.value = settings.currencyCode;

    if (hasEditing && _wallet != null) {
      final rawBook = _walletController.bookBalanceOf(_wallet!.id);
      final result = await _walletController.conversionService.convertAmount(
        amount: rawBook,
        fromCurrency: _wallet!.currencyCode,
        toCurrency: settings.currencyCode,
      );
      final convertedVal = result.tryGetSuccess() ?? rawBook;
      amountStr.value = convertedVal.toString();
    }

    await _loadEmergencyFundGate();
    await _loadInvestmentCategories();
  }

  Future<void> _loadInvestmentCategories() async {
    final result = await _getCategories.call();
    result.when((categories) {
      final enabledInvestment = categories
          .where((c) => c.type == CategoryType.investment && c.hasEnabled)
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
    hasNameValid.value = nameController.text.trim().isNotEmpty;
    if (nameError.value != null) {
      nameError.value = null;
    }
  }

  Future<void> _loadEmergencyFundGate() async {
    emergencyFundUnlocked.value = await _emergencyFund.hasUnlocked();
  }

  Future<void> openEmergencyFundEbook(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebPage(
          url: emergencyFundEbookUrl,
          title: el.tr(PrjLocaleKeys.wallet_emergency_fund),
        ),
      ),
    );
    await _emergencyFund.markEbookViewed();
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
    _validateAmount();
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
    _validateAmount();
  }

  void _validateAmount() {
    final amount = int.tryParse(amountStr.value) ?? 0;
    hasAmountValid.value = amount > 0;
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

  void onClearAmount() {
    amountStr.value = '0';
    _validateAmount();
  }

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

  void onQuickAmountSelected(int amount) {
    amountStr.value = amount.toString();
    _validateAmount();
  }

  Future<void> save(BuildContext context) async {
    if (hasSubmitting.value) return;
    hasSubmitting.value = true;

    final name = hasNameLocked ? _wallet!.name : nameController.text.trim();
    final balance = int.tryParse(amountStr.value) ?? 0;
    final wallet = _wallet;

    // Check for duplicate names (excluding current wallet if editing)
    final hasDuplicate =
        !hasNameLocked &&
        _walletController.wallets.any(
          (w) =>
              w.name.trim().toLowerCase() == name.toLowerCase() &&
              w.id != wallet?.id,
        );

    if (hasDuplicate) {
      nameError.value = el.tr(PrjLocaleKeys.wallet_name_duplicate_error);
      hasSubmitting.value = false;
      return;
    }

    try {
      if (wallet != null) {
        final int targetBalance;
        if (balanceLocked) {
          if (wallet.currencyCode.toUpperCase() ==
              currencyCode.value.toUpperCase()) {
            targetBalance = wallet.balance;
          } else {
            final conv = await _walletController.conversionService
                .convertAmount(
                  amount: wallet.balance,
                  fromCurrency: wallet.currencyCode,
                  toCurrency: currencyCode.value,
                );
            targetBalance = conv.tryGetSuccess() ?? wallet.balance;
          }
        } else {
          targetBalance = balance;
        }

        await _walletController.updateWallet(
          WalletEntity(
            id: wallet.id,
            name: name,
            balance: targetBalance,
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
            currencyCode: currencyCode.value,
          ),
        );
      } else {
        _walletController.errorMessage.value = '';
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

        if (_walletController.errorMessage.value.isNotEmpty) {
          if (context.mounted) {
            CcSnackBarHelper.showErrorSnackBar(
              context: context,
              message: _walletController.errorMessage.value,
            );
          }
          return;
        }
      }

      if (context.mounted) {
        // Refresh related controllers immediately to reflect memory changes
        _walletController.loadWallets();
        await _effects.afterSheetSaved(created: !hasEditing);

        if (!context.mounted) return;
        Navigator.pop(context);
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: hasEditing
              ? el.tr(PrjLocaleKeys.wallet_updated_success)
              : el.tr(PrjLocaleKeys.wallet_added_success),
        );
        if (!hasEditing && context.mounted) {
          _effects.promptGuestSignIn(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(PrjLocaleKeys.app_error_general),
        );
      }
    } finally {
      hasSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
