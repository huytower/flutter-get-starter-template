import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../budget_limit/presentation/get_x/budget_limit_controller.dart';
import '../../../liability/presentation/get_x/liability_list_controller.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
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
  final RxBool hasNoteText = false.obs;
  final RxString currencyCode = CurrencyConstants.defaultCurrencyCode.obs;

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
    _loadCurrency();
    ever(CurrencyConstants.onCurrencyChanged, (_) => _loadCurrency());
    noteController.addListener(_updateNoteState);
    layoutStatus.value = CcLayoutStatus.success;
  }

  Future<void> _loadCurrency() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    currencyCode.value = settings.currencyCode;
  }

  void _updateNoteState() {
    hasNoteText.value = noteController.text.trim().isNotEmpty;
  }

  @override
  void onClose() {
    _walletsWorker?.dispose();
    noteController.removeListener(_updateNoteState);
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

  Future<void> resetForm() async {
    amountStr.value = '0';
    noteController.clear();
    date.value = DateTime.now();
    showKeypad.value = false;
    _notifyParentKeypad(false);
    await onReset();
  }

  Future<void> onReset();

  void showKeypadAndScroll(BuildContext context, {GlobalKey? fieldKey}) {
    FocusScope.of(context).unfocus();
    showKeypad.value = true;
    _notifyParentKeypad(true);
    // Wait for the 200ms header collapse animation to complete before scrolling
    Future.delayed(const Duration(milliseconds: 220), () {
      final ctx = (fieldKey ?? amountFieldKey).currentContext;
      if (ctx != null && ctx.mounted) {
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
    if (wallets.any((w) => w.id == id)) {
      selectedWalletId.value = id;
    }
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

  /// Refreshes all parent controllers concurrently using [Future.wait].
  Future<void> refreshParent() async {
    final futures = <Future<void>>[];

    if (Get.isRegistered<TransactionController>()) {
      final parent = Get.find<TransactionController>();
      futures.add(
        parent.refreshData().then((_) {
          parent.flashWalletSummary();
          _loadWallets();
        }),
      );
    }

    if (Get.isRegistered<WalletController>()) {
      futures.add(Get.find<WalletController>().loadWallets(showLoading: false));
    }

    if (Get.isRegistered<ReportController>()) {
      futures.add(Get.find<ReportController>().load(showLoading: false));
    }

    if (Get.isRegistered<BudgetLimitController>()) {
      futures.add(Get.find<BudgetLimitController>().loadBudgets());
    }

    if (Get.isRegistered<LiabilityListController>()) {
      futures.add(Get.find<LiabilityListController>().load());
    }

    await Future.wait(futures);
  }

  bool get canSubmit;

  void clearCategorySelection();

  void submitForm(BuildContext context);
}
