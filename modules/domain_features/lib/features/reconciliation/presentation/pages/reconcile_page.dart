import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../get_x/reconciliation_controller.dart';
import '../widgets/reconciliation_confirm_button.dart';
import '../widgets/reconciliation_dialogs.dart';
import '../widgets/reconciliation_history_section.dart';
import '../widgets/reconciliation_mismatch_warning.dart';
import '../widgets/reconciliation_summary.dart';
import '../widgets/wallet_reconcile_tile.dart';

@RoutePage()
class ReconcilePage extends CcGetView<ReconciliationController> {
  const ReconcilePage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
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
      title: CcText(
        el.tr(CcLocaleKeys.reconciliation_title),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
          fontSize: context.respFontSize(CcTypographyParams.titleMedium),
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
        SizedBox(width: context.respPadding(CcPaddingParams.SPACE_SM)),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context,
    ReconciliationController controller,
  ) async {
    final error = await controller.performReconciliation();
    if (!context.mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReconciliationSuccessDialog(
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(() {
      if (controller.balances.isEmpty) {
        return Center(
          child: CcText(
            el.tr(CcLocaleKeys.reconciliation_empty),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
        );
      }

      final isEditing = controller.editingWalletId.value != null;

      return Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: controller.stopEditing,
              child: ListView(
                padding: EdgeInsets.all(
                  context.respPadding(CcPaddingParams.SPACE_MD),
                ),
                children: [
                  CcText(
                    el.tr(CcLocaleKeys.reconciliation_description_line_1),
                    maxLines: 3,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                  const CcSpaceXS(),
                  CcText(
                    el.tr(CcLocaleKeys.reconciliation_description_line_2),
                    maxLines: 3,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                  const CcSpaceXS(),
                  CcText(
                    el.tr(CcLocaleKeys.reconciliation_cycle_subtitle),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                        0.6,
                      ),
                      fontSize: context.respFontSize(
                        CcTypographyParams.bodySmall,
                      ),
                    ),
                  ),
                  const CcSpaceXS(),
                  CcText(
                    el.tr(CcLocaleKeys.reconciliation_instruction),
                    textStyle: context.ccTextTheme.bodyMedium,
                  ),
                  const CcSpaceXS(),
                  Column(
                    children: controller.balances.map((balance) {
                      return WalletReconcileTile(
                        balance: balance,
                        onActualChanged: (value) =>
                            controller.setActual(balance.wallet.id, value),
                        onAcknowledge: () =>
                            controller.acknowledgeAdjustment(balance.wallet.id),
                      );
                    }).toList(),
                  ),
                  const ReconciliationMismatchWarning(),
                  const Divider(height: 24),
                  const ReconciliationSummary(),
                  const CcSpaceMD(),
                  const ReconciliationConfirmButton(),
                  const Divider(height: 32),
                  const ReconciliationHistorySection(),
                ],
              ),
            ),
          ),
          if (isEditing)
            SafeArea(
              top: false,
              child: MoneyKeypadPanel(
                onKeyPress: controller.updateAmount,
                onDelete: controller.deleteChar,
                onClear: controller.clearAmount,
                suggestions: const [
                  100000,
                  200000,
                  500000,
                  1000000,
                  2000000,
                  5000000,
                ],
                onSuggestion: (value) => controller.setAmount(value),
                onDone: controller.stopEditing,
                activeColor: context.ccColorScheme.primary,
              ),
            ),
        ],
      );
    });
  }
}
