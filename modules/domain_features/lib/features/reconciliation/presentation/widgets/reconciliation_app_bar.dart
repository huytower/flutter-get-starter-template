import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/gradient_app_bar.dart';
import '../get_x/reconciliation_controller.dart';
import '../widgets/reconciliation_dialogs.dart';

class ReconciliationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReconciliationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    return buildDomainGradientAppBar(
      context,
      leading: CcIconButton.bouncing(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
        onTap: () => Navigator.of(context).pop(),
      ),
      title: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CcText(
              el.tr(CcLocaleKeys.reconciliation_title),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: context.ccColorScheme.onPrimary,
                fontWeight: CcTypographyParams.bold,
                fontSize: context.respFontSize(CcTypographyParams.titleMedium),
              ),
            ),
            CcText(
              el.tr(CcLocaleKeys.reconciliation_cycle_subtitle),
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: context.ccColorScheme.onPrimary.withOpacity(0.9),
                fontSize: context.respFontSize(CcTypographyParams.bodySmall),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Builder(
          builder: (context) => Obx(() {
            final enabled =
                !controller.isSubmitting.value &&
                controller.unhandledCount.value == 0 &&
                controller.balances.isNotEmpty;
            return CcIconButton.bouncing(
              icon: Icon(
                Icons.check_circle_outline,
                size: context.respIconSize(baseSize: 24),
                color: context.ccColorScheme.onPrimary,
              ),
              tooltip: el.tr(CcLocaleKeys.reconciliation_confirm),
              onTap: enabled ? () => _confirm(context, controller) : () {},
              isEnable: enabled,
              useDebounce: true,
            );
          }),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context, ReconciliationController controller) async {
    final error = await controller.performReconciliation();
    if (!context.mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ReconciliationSuccessDialog(),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst || route is! DialogRoute);
          Navigator.of(context).pop();
        }
      });
    }
  }
}
