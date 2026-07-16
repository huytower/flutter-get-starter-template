import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/transaction/presentation/get_x/transaction_controller.dart';
import '../features/transaction/presentation/widgets/cc_form_label.dart';
import '../features/wallet/domain/entities/wallet_entity.dart';
import 'transaction_form_helpers.dart';

/// Mixin providing common functionality for transaction forms (expense, income, transfer).
/// Reduces code duplication across form widgets.
mixin TransactionFormMixin<T extends StatefulWidget> on State<T> {
  // Common state variables
  String amountStr = '0';
  final TextEditingController noteController = TextEditingController();
  final scrollController = ScrollController();
  final amountFieldKey = GlobalKey();

  List<WalletEntity> wallets = const [];
  DateTime date = DateTime.now();
  bool isSubmitting = false;
  bool showKeypad = false;
  bool showMoreDetails = false;

  // Abstract getters that each form must implement
  Color get accentColor;
  String? get selectedWalletId;
  void Function(String) get onWalletSelected;

  @override
  void dispose() {
    noteController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  /// Loads wallets from the shared TransactionController to avoid duplicate API calls.
  void loadWalletsFromController({
    String? initialFromWalletId,
    String? initialToWalletId,
    void Function(List<WalletEntity>)? onWalletsLoaded,
  }) {
    final controller = Get.find<TransactionController>();
    wallets = controller.wallets;

    if (onWalletsLoaded != null) {
      onWalletsLoaded(wallets);
    }

    // Listen to wallet changes
    ever(controller.wallets, (wallets) {
      if (mounted) {
        setState(() {
          this.wallets = wallets;
          onWalletsLoaded?.call(wallets);
        });
      }
    });
  }

  /// Handles keypad key press for amount input.
  void onKeyPress(String key) {
    setState(() {
      if (amountStr == '0') {
        if (key != '0' && key != '000') {
          amountStr = key;
        }
      } else {
        amountStr += key;
      }
    });
  }

  /// Handles delete key press for amount input.
  void onDelete() {
    setState(() {
      if (amountStr.length > 1) {
        amountStr = amountStr.substring(0, amountStr.length - 1);
      } else {
        amountStr = '0';
      }
    });
  }

  /// Picks a date using the date picker helper.
  Future<void> pickDate() async {
    final picked = await TransactionFormHelpers.pickDate(context, date);
    if (picked == null) return;
    setState(() {
      date = TransactionFormHelpers.updateDatePreserveTime(date, picked);
    });
  }

  /// Composes note from the note controller.
  String? composeNote() {
    return TransactionFormHelpers.composeNote(noteController);
  }

  /// Resets the form to initial state.
  void resetForm({Void? Function()? onReset}) {
    setState(() {
      amountStr = '0';
      noteController.clear();
      date = DateTime.now();
      showKeypad = false;
      onReset?.call();
    });
  }

  /// Shows the keypad and scrolls to the amount field.
  void showKeypadAndScroll() {
    FocusScope.of(context).unfocus();
    setState(() => showKeypad = true);
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

  /// Hides the keypad.
  void hideKeypad() {
    setState(() => showKeypad = false);
  }

  /// Builds a form label widget.
  Widget buildLabel(String text) {
    return CcFormLabel(text: text);
  }
}
