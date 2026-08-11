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
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../profile/domain/usecases/update_profile_settings_usecase.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import 'wallet_controller.dart';

/// Backs [AddWalletSheet] — create/edit form state for a single wallet.
/// Instantiated fresh per sheet open via [init]; see the sheet's
/// `initState`/`dispose` for the `Get.put`/`Get.delete` lifecycle.
@injectable
class AddWalletSheetController extends CcGetController {
  AddWalletSheetController(this._walletController);

  final WalletController _walletController;

  WalletEntity? _wallet;
  late final TextEditingController nameController;

  /// Opening balance as a raw digit string (e.g. "1000000"), mirroring the
  /// transaction amount input pattern.
  final RxString amountStr = '0'.obs;
  final RxBool showKeypad = false.obs;
  final GlobalKey amountFieldKey = GlobalKey();

  /// Type of a newly created wallet — the cash wallet is a fixed singleton,
  /// so only bank/credit can be added.
  final RxString newType = WalletType.bank.obs;

  final RxBool emergencyFundUnlocked = false.obs;
  final RxBool showEmergencyFundLockedHint = false.obs;
  final RxBool isNameValid = false.obs;

  bool get isEditing => _wallet != null;

  /// The cash wallet keeps its fixed default name and icon.
  bool get isCash => _wallet?.type == WalletType.cash;

  /// Opening balance is locked once the wallet has any transaction (rule 1).
  bool get balanceLocked =>
      isEditing && _walletController.walletHasTransactions(_wallet!.id);

  void init(WalletEntity? wallet) {
    _wallet = wallet;
    nameController = TextEditingController(text: wallet?.name ?? '');
    nameController.addListener(_onNameChanged);
    _onNameChanged();
    if (isEditing) {
      // Use the current book balance for display consistency (the "real"
      // balance the user sees in the list).
      amountStr.value = _walletController.bookBalanceOf(wallet!.id).toString();
    }
    _loadEmergencyFundGate();
  }

  void _onNameChanged() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  Future<void> _loadEmergencyFundGate() async {
    final level = getIt<UserLevelController>().status.value.level;
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    emergencyFundUnlocked.value =
        level >= 2 && settings.hasViewedEmergencyFundEbook;
  }

  Future<void> openEmergencyFundEbook(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WebPage(url: emergencyFundEbookUrl),
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
    // Dismiss the OS keyboard (if the name field is focused) and show the
    // custom money keypad instead — consistent with the transaction pages.
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
  }

  Future<void> save(BuildContext context) async {
    final name = nameController.text.trim();
    final balance = int.tryParse(amountStr.value) ?? 0;
    final wallet = _wallet;

    if (wallet != null) {
      await _walletController.updateWallet(
        WalletEntity(
          id: wallet.id,
          name: name,
          balance: balance,
          iconCode: wallet.iconCode,
          type: wallet.type,
          createdAt: wallet.createdAt,
          categoryId: wallet.categoryId,
        ),
      );
    } else {
      await _walletController.addWallet(
        name: name,
        initialBalance: balance,
        iconCode: walletIconFor(newType.value).codePoint,
        type: newType.value,
      );
    }

    if (context.mounted) {
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
