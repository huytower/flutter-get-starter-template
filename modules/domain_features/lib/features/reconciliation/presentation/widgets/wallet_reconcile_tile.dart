import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../../core/util/money_format_helper.dart';
import '../../../wallet/domain/entities/wallet_balance_entity.dart';
import '../get_x/reconciliation_controller.dart';

class WalletReconcileTile extends StatelessWidget {
  final WalletBalanceEntity balance;
  final ValueChanged<int> onActualChanged;
  final VoidCallback onAcknowledge;

  const WalletReconcileTile({
    super.key,
    required this.balance,
    required this.onActualChanged,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();

    return Obx(() {
      final actual = controller.actualOf(balance.wallet.id);
      final diff = actual - balance.bookBalance;
      final isBalanced = diff == 0;
      final isAcknowledged = controller.isAcknowledged(balance.wallet.id);
      final isResolved = isBalanced || isAcknowledged;
      final isEditing = controller.editingWalletId.value == balance.wallet.id;
      final scheme = context.ccColorScheme;

      final statusColor = isResolved ? scheme.primary : scheme.error;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: isEditing
              ? Border.all(color: scheme.primary, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CcText(
                  balance.wallet.name,
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CcText(
                  el.tr(
                    CcLocaleKeys.reconciliation_book_balance,
                    namedArgs: {
                      'amount': formatVndWithSymbol(balance.bookBalance),
                    },
                  ),
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            WalletActualBalanceInput(
              actual: actual,
              isEditing: isEditing,
              onTap: () => controller.startEditing(balance.wallet.id),
              onClear: () {
                if (isEditing) {
                  controller.clearAmount();
                } else {
                  controller.setActual(balance.wallet.id, 0);
                }
              },
            ),
            const SizedBox(height: 10),
            WalletReconcileStatusRow(
              isBalanced: isBalanced,
              isAcknowledged: isAcknowledged,
              diff: diff,
              statusColor: statusColor,
              onAcknowledge: onAcknowledge,
            ),
          ],
        ),
      );
    });
  }
}

class WalletActualBalanceInput extends StatelessWidget {
  final int actual;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const WalletActualBalanceInput({
    super.key,
    required this.actual,
    required this.isEditing,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        CcText(
          el.tr(CcLocaleKeys.reconciliation_actual),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        const CcSpaceMD(),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEditing
                    ? scheme.primary
                    : scheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CcText(
                  '${TransactionFormHelpers.formatAmount(actual.toString())} đ',
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEditing ? scheme.primary : null,
                  ),
                ),
                if (actual != 0) ...[
                  const CcSpaceSM(),
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.cancel,
                      size: 18,
                      color: scheme.onSurfaceVariant.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WalletReconcileStatusRow extends StatelessWidget {
  final bool isBalanced;
  final bool isAcknowledged;
  final int diff;
  final Color statusColor;
  final VoidCallback onAcknowledge;

  const WalletReconcileStatusRow({
    super.key,
    required this.isBalanced,
    required this.isAcknowledged,
    required this.diff,
    required this.statusColor,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    if (isBalanced) {
      return Row(
        children: [
          const CcIconToken(Icons.check_circle_outline, size: 16),
            const CcSpaceXS(),
          CcText(
            el.tr(CcLocaleKeys.reconciliation_matched),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isAcknowledged ? Icons.check_circle_outline : Icons.error_outline,
              color: statusColor,
              size: 16,
            ),
          const CcSpaceXS(),
            CcText(
              el.tr(
                CcLocaleKeys.reconciliation_lech,
                namedArgs: {
                  'amount':
                      '${diff > 0 ? '+' : ''}${diff < 0 ? '-' : ''}${formatVndWithSymbol(diff.abs())}',
                },
              ),
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (!isAcknowledged)
          GestureDetector(
            onTap: onAcknowledge,
            child: CcText(
              el.tr(CcLocaleKeys.reconciliation_create_adjustment),
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: scheme.error,
              ),
            ),
          )
        else
          CcText(
            el.tr(CcLocaleKeys.common_done),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
