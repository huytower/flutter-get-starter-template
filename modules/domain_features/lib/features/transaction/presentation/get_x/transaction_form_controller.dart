import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/entities/transaction_entity.dart';
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

  Worker? _walletsWorker;

  /// Set (via [loadForEdit]) when this controller instance is editing an
  /// existing transaction rather than recording a new one.
  TransactionEntity? editingTransaction;

  bool get isEditing => editingTransaction != null;

  /// Called by [submitForm] after a successful edit — the edit sheet uses
  /// this to close itself instead of the create flow's reset-and-stay.
  VoidCallback? onEditSaved;

  @override
  void onInit() {
    super.onInit();
    _loadWallets();
    layoutStatus.value = CcLayoutStatus.success;
  }

  @override
  void onClose() {
    _walletsWorker?.dispose();
    noteController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _loadWallets() {
    final parentController = Get.find<TransactionController>();
    wallets.assignAll(_liquidOnly(parentController.wallets));

    if (selectedWalletId.value == null && wallets.isNotEmpty) {
      selectedWalletId.value = wallets.first.id;
    }

    // Listen to changes in parent's wallets
    _walletsWorker = ever(parentController.wallets, (
      List<WalletEntity> newWallets,
    ) {
      wallets.assignAll(_liquidOnly(newWallets));
      if (selectedWalletId.value == null && wallets.isNotEmpty) {
        selectedWalletId.value = wallets.first.id;
      }
    });
  }

  /// Prefills the form from [transaction] for editing. Category selection is
  /// left to the category picker itself (pass `transaction.categoryId` as
  /// its initial-selection id) so it resolves the real [CategoryEntity] from
  /// its own data source instead of reconstructing one from denormalized
  /// fields here.
  void loadForEdit(TransactionEntity transaction) {
    editingTransaction = transaction;
    amountStr.value = transaction.amount.toString();
    selectedWalletId.value = transaction.walletId;
    date.value = transaction.date;
    noteController.text = transaction.note ?? '';
  }

  /// Investment positions (`WalletType.investment`) aren't spendable/receivable
  /// like a normal wallet, so they never appear as a liquid-wallet choice here.
  List<WalletEntity> _liquidOnly(List<WalletEntity> source) =>
      source.where((w) => w.type != WalletType.investment).toList();

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
    _notifyParentKeypad(false);
    onReset();
  }

  void onReset();

  void showKeypadAndScroll(BuildContext context) {
    FocusScope.of(context).unfocus();
    showKeypad.value = true;
    _notifyParentKeypad(true);
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
    _notifyParentKeypad(false);
  }

  void _notifyParentKeypad(bool open) {
    if (Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().isKeypadOpen.value = open;
    }
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
  Future<void> refreshParent() async {
    if (Get.isRegistered<TransactionController>()) {
      final parent = Get.find<TransactionController>();
      await parent.refreshData();
      parent.flashWalletSummary();
      _loadWallets();
    }
  }

  bool get canSubmit;

  void submitForm(BuildContext context);
}
