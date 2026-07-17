import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import 'transaction_controller.dart';

abstract class TransactionFormController extends CcGetController {
  final RxString amountStr = '0'.obs;
  final TextEditingController noteController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final GlobalKey amountFieldKey = GlobalKey();

  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool isSubmitting = false.obs;
  final RxBool showKeypad = false.obs;
  final RxBool showMoreDetails = false.obs;

  final Rx<String?> selectedWalletId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadWallets();
    layoutStatus.value = CcLayoutStatus.success;
  }

  @override
  void onClose() {
    noteController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _loadWallets() {
    final parentController = Get.find<TransactionController>();
    wallets.assignAll(parentController.wallets);

    if (selectedWalletId.value == null && wallets.isNotEmpty) {
      selectedWalletId.value = wallets.first.id;
    }

    // Listen to changes in parent's wallets
    ever(parentController.wallets, (List<WalletEntity> newWallets) {
      wallets.assignAll(newWallets);
      if (selectedWalletId.value == null && wallets.isNotEmpty) {
        selectedWalletId.value = wallets.first.id;
      }
    });
  }

  void handleKeyPress(String key) {
    if (amountStr.value == '0') {
      if (key != '0' && key != '000') {
        amountStr.value = key;
      }
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

  Future<void> pickDate(BuildContext context) async {
    final picked = await TransactionFormHelpers.pickDate(context, date.value);
    if (picked == null) return;
    date.value = TransactionFormHelpers.updateDatePreserveTime(
      date.value,
      picked,
    );
  }

  String? composeNote() {
    return TransactionFormHelpers.composeNote(noteController);
  }

  void resetForm() {
    amountStr.value = '0';
    noteController.clear();
    date.value = DateTime.now();
    showKeypad.value = false;
    onReset();
  }

  void onReset();

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

  void hideKeypad() {
    showKeypad.value = false;
  }

  void setWalletId(String id) {
    selectedWalletId.value = id;
  }

  void toggleMoreDetails() {
    showMoreDetails.value = !showMoreDetails.value;
  }

  void setDate(DateTime newDate) {
    date.value = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      date.value.hour,
      date.value.minute,
    );
  }

  /// Refreshes the parent [TransactionController] data after a successful transaction.
  void refreshParent() {
    if (Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().refreshData();
    }
  }

  bool get canSubmit;

  void submitForm(BuildContext context);
}
