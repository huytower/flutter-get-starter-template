import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/transaction_form_helpers.dart';
import '../../domain/usecases/create_transfer_usecase.dart';
import 'transaction_form_controller.dart';

@injectable
class TransferFormController extends TransactionFormController {
  final Rx<String?> toWalletId = Rx<String?>(null);

  final List<int> quickAmounts = const [
    10000,
    20000,
    30000,
    50000,
    100000,
    200000,
    300000,
    500000,
    1000000,
    2000000,
  ];

  @override
  void onInit() {
    super.onInit();
    if (wallets.length > 1) {
      toWalletId.value = wallets[1].id;
    }
  }

  @override
  bool get canSubmit =>
      selectedWalletId.value != null &&
      toWalletId.value != null &&
      selectedWalletId.value != toWalletId.value &&
      amountStr.value != '0' &&
      amountStr.value.isNotEmpty;

  @override
  void onReset() {
    // Transfer specific reset if needed
  }

  void setToWalletId(String id) {
    if (selectedWalletId.value == id) {
      selectedWalletId.value = toWalletId.value;
    }
    toWalletId.value = id;
  }

  @override
  void setWalletId(String id) {
    if (toWalletId.value == id) {
      toWalletId.value = selectedWalletId.value;
    }
    selectedWalletId.value = id;
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final params = CreateTransferParams(
      fromWalletId: selectedWalletId.value ?? '',
      toWalletId: toWalletId.value ?? '',
      amount: int.tryParse(amountStr.value) ?? 0,
      note: composeNote(),
      date: date.value,
    );

    final result = await getIt<CreateTransferUseCase>().call(params);
    isSubmitting.value = false;

    result.when(
      (_) {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_transfer_saved,
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
