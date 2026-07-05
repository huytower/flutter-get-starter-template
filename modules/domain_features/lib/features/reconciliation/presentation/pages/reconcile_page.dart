import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../get_x/reconciliation_controller.dart';
import '../widgets/reconciliation_history_card.dart';
import '../widgets/wallet_reconcile_tile.dart';

@RoutePage()
class ReconcilePage extends CcGetView<ReconciliationController> {
  const ReconcilePage({super.key});

  static String _money(int value) =>
      '${value.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ';

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      title: Builder(
        builder: (context) => CcText(
          el.tr(CcLocaleKeys.reconciliation_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Get.context?.ccColorScheme.primary,
      elevation: 0,
    );
  }

  @override
  Widget? buildContent() {
    return Builder(
      builder: (context) {
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

        return ListView(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          children: [
            CcText(
              el.tr(CcLocaleKeys.reconciliation_instruction),
              textStyle: context.ccTextTheme.bodyMedium,
            ),
            const CcSpaceSM(),
            ...controller.balances.map(
              (balance) => WalletReconcileTile(
                balance: balance,
                onActualChanged: (value) =>
                    controller.setActual(balance.wallet.id, value),
              ),
            ),
            const Divider(height: 24),
            _buildSummary(context),
            const CcSpaceMD(),
            _buildConfirmButton(context),
            const Divider(height: 32),
            _buildHistorySection(context),
          ],
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Obx(() {
      final diff = controller.difference;
      return Column(
        children: [
          _summaryRow(context, el.tr(CcLocaleKeys.reconciliation_book_total), _money(controller.systemTotal.value)),
          _summaryRow(context, el.tr(CcLocaleKeys.reconciliation_actual_total), _money(controller.actualTotal.value)),
          const CcSpaceXS(),
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_difference),
            diff == 0
                ? el.tr(CcLocaleKeys.reconciliation_balanced)
                : el.tr(
                    diff > 0
                        ? CcLocaleKeys.reconciliation_surplus
                        : CcLocaleKeys.reconciliation_deficit,
                    namedArgs: {'amount': _money(diff.abs())},
                  ),
            color: diff == 0 ? scheme.primary : scheme.error,
          ),
        ],
      );
    });
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CcText(
            label,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          CcText(
            value,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Obx(() {
      final busy = controller.isSubmitting.value;
      return SizedBox(
        width: double.infinity,
        height: context.respDim(50),
        child: ElevatedButton(
          onPressed: busy
              ? null
              : () async {
                  final error = await controller.performReconciliation();
                  if (!context.mounted) return;
                  if (error != null) {
                    CcSnackBarHelper.showErrorSnackBar(
                      context: context,
                      message: error,
                    );
                  } else {
                    CcSnackBarHelper.showSuccessSnackBar(
                      context: context,
                      message: el.tr(CcLocaleKeys.reconciliation_success),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.ccColorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: busy
              ? SizedBox(
                  width: context.respDim(20),
                  height: context.respDim(20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.ccColorScheme.onPrimary,
                  ),
                )
              : CcText(
                  el.tr(CcLocaleKeys.reconciliation_confirm),
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildHistorySection(BuildContext context) {
    return Obx(() {
      if (controller.history.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(CcLocaleKeys.reconciliation_history),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _confirmUndo(context),
                icon: const Icon(Icons.undo, size: 18),
                label: Text(el.tr(CcLocaleKeys.reconciliation_undo)),
              ),
            ],
          ),
          const CcSpaceSM(),
          ...controller.history.map(
            (r) => ReconciliationHistoryCard(reconciliation: r),
          ),
        ],
      );
    });
  }

  void _confirmUndo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(el.tr(CcLocaleKeys.reconciliation_undo_title)),
        content: Text(el.tr(CcLocaleKeys.reconciliation_undo_confirm)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(el.tr(CcLocaleKeys.common_cancel)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.isSubmitting.value) return;
              Navigator.pop(dialogContext);
              final error = await controller.undoLast();
              if (!context.mounted) return;
              if (error != null) {
                CcSnackBarHelper.showErrorSnackBar(
                  context: context,
                  message: error,
                );
              }
            },
            child: Text(el.tr(CcLocaleKeys.reconciliation_undo)),
          ),
        ],
      ),
    );
  }
}
