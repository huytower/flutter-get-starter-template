import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
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
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CcText(
            el.tr(CcLocaleKeys.reconciliation_title),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: CcTypographyParams.bold,
            ),
          ),
          CcText(
            el.tr(CcLocaleKeys.reconciliation_cycle_subtitle),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => Obx(() {
            final enabled =
                !controller.isSubmitting.value &&
                controller.unhandledCount.value == 0 &&
                controller.balances.isNotEmpty;
            return IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                size: context.respIconSize(baseSize: 24),
                color: context.ccColorScheme.onPrimary,
              ),
              tooltip: el.tr(CcLocaleKeys.reconciliation_confirm),
              onPressed: enabled ? () => _confirm(context) : null,
              constraints: BoxConstraints(
                minWidth: context.respDim(40),
                minHeight: context.respDim(40),
              ),
              padding: EdgeInsets.zero,
            );
          }),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final error = await controller.performReconciliation();
    if (!context.mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
    } else {
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: el.tr(CcLocaleKeys.reconciliation_success),
      );
    }
  }

  @override
  Widget? buildContent(BuildContext context) {
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
            Obx(
              () => Column(
                children: controller.balances.map((balance) {
                  return WalletReconcileTile(
                    balance: balance,
                    isAcknowledged: controller.isAcknowledged(
                      balance.wallet.id,
                    ),
                    onActualChanged: (value) =>
                        controller.setActual(balance.wallet.id, value),
                    onAcknowledge: () =>
                        controller.acknowledgeAdjustment(balance.wallet.id),
                  );
                }).toList(),
              ),
            ),
            _buildMismatchWarning(context),
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

  Widget _buildMismatchWarning(BuildContext context) {
    return Obx(() {
      final count = controller.unhandledCount.value;
      if (count == 0) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.ccColorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.ccColorScheme.error.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: context.ccColorScheme.error,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CcText(
                el.tr(
                  CcLocaleKeys.reconciliation_mismatch_warning,
                  namedArgs: {'count': count.toString()},
                ),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: context.ccColorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummary(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Obx(() {
      final diff = controller.difference;
      final diffText = diff == 0
          ? el.tr(CcLocaleKeys.reconciliation_balanced)
          : '${diff < 0 ? '-' : '+'}${_money(diff.abs())}';
      return Column(
        children: [
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_book_total),
            _money(controller.systemTotal.value),
          ),
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_actual_total),
            _money(controller.actualTotal.value),
          ),
          const CcSpaceXS(),
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_difference),
            diffText,
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
      final hasWarning = controller.unhandledCount.value > 0;
      return SizedBox(
        width: double.infinity,
        height: context.respDim(50),
        child: ElevatedButton(
          onPressed: busy || hasWarning ? null : () => _confirm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.ccColorScheme.primary,
            alignment: Alignment.center,
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
              : Text(
                  el.tr(CcLocaleKeys.reconciliation_confirm),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
