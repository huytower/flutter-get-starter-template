import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/base/cc_keyboard_dismisser.dart';
import '../../widgets/dialog/cc_base_dialog.dart';
import '../../widgets/dialog/cc_body_modal_bottom_sheet.dart';
import '../../widgets/dialog/cc_body_show_message.dart';
import '../../widgets/state/cc_loading_icon_widget.dart';
import '../extensions/cc_context_extension.dart';
import '../extensions/common/cc_responsive_extension.dart';

/// CcDialogHelper: Standardized utility for showing dialogs, bottom sheets, and loaders.
///
/// This helper consolidates all modal-related operations into a single point of access,
/// ensuring consistent styling, behavior, and naming conventions.
class CcDialogHelper {
  // ==========================================================================
  // BOTTOM SHEETS
  // ==========================================================================

  /// Shows a modal bottom sheet with a custom widget.
  static Future<T?> showModalBottomSheet<T>(
    BuildContext context,
    Widget child, {
    bool isHasIgnore = false,
    bool enableDrag = true,
    double border = 10.0,
  }) {
    return m.showModalBottomSheet<T>(
      context: context,
      enableDrag: enableDrag,
      isDismissible: enableDrag,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(border)),
      ),
      backgroundColor: context.ccColorScheme.surface,
      isScrollControlled: true,
      builder: (context) {
        Widget body = SafeArea(child: CcBodyModalBottomSheet(w: child));

        if (isHasIgnore) {
          return body;
        }
        return CcKeyboardDismisser(child: body);
      },
    );
  }

  /// Shows a specialized message bottom sheet (legacy: showDialogMessage).
  static Future<bool> showMessageBottomSheet({
    BuildContext? context,
    Widget? customWidget,
    bool isExistOK = false,
    bool isDrag = true,
    String content = '',
    String title = '',
    VoidCallback? onClose,
    VoidCallback? onTapOK,
  }) async {
    final targetContext = context ?? Get.context!;
    bool result = false;

    await m.showModalBottomSheet(
      context: targetContext,
      enableDrag: isDrag,
      isDismissible: isDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      backgroundColor: targetContext.ccColorScheme.surface,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: CcBodyShowMessage(
            title: title,
            content: content,
            onTabOK: () {
              result = true;
              if (onTapOK != null) {
                onTapOK();
                return;
              }
              exit(0);
            },
            isExistOK: isExistOK,
            child:
                customWidget ??
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: context.respFontSize(17.0)),
                ),
          ),
        );
      },
    );

    if (onClose != null) {
      onClose();
    }
    return result;
  }

  // ==========================================================================
  // DIALOGS
  // ==========================================================================

  /// Shows a project-standard confirmation dialog.
  static Future<void> showConfirmationDialog({
    VoidCallback? onTapCancel,
    required VoidCallback? onTapConfirm,
    Color? bgColor,
    Color? bgColorBarrier,
    String? agreeText,
    String? cancelText,
    Color? confirmTextColor,
    required String desc,
    Color? descTextColor,
    bool isActionBtnVisible = true,
    bool isAllowDismiss = true,
    bool isAutoDismiss = false,
    bool isCancelBtnShown = false,
    CcDialogStatus status = CcDialogStatus.ERROR,
  }) async {
    try {
      await Get.dialog(
        CcBaseDialog(
          onTapCancel: onTapCancel,
          onTapConfirm: onTapConfirm,
          agreeText: agreeText,
          bgColor: bgColor,
          cancelText: cancelText,
          confirmTextColor: confirmTextColor,
          desc: desc,
          descTextColor: descTextColor,
          isCancelBtnShown: isCancelBtnShown,
          isActionBtnVisible: isActionBtnVisible,
          status: status,
        ),
        barrierDismissible: isAllowDismiss,
        barrierColor: bgColorBarrier ?? Colors.black.withOpacity(0.5),
      );

      if (isAutoDismiss) {
        await Future.delayed(const Duration(seconds: 2));
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error showing confirmation dialog: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Shows a persistent loading dialog.
  static Future<void> showLoadingDialog({BuildContext? context}) async {
    final targetContext = context ?? Get.context!;
    await showDialog<void>(
      context: targetContext,
      barrierDismissible: false,
      barrierColor: Colors.grey.withOpacity(0.3),
      builder: (BuildContext context) {
        return const PopScope(
          canPop: false,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CcLoadingIconWidget(),
          ),
        );
      },
    );
  }
}
