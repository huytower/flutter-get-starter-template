import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/transaction_form_helpers.dart';
import '../../../wallet/domain/entities/wallet_balance_entity.dart';
import '../get_x/reconciliation_controller.dart';

class WalletReconcileTile extends StatelessWidget {
  final WalletBalanceEntity balance;
  final bool isAcknowledged;
  final ValueChanged<int> onActualChanged;
  final VoidCallback onAcknowledge;

  const WalletReconcileTile({
    super.key,
    required this.balance,
    required this.isAcknowledged,
    required this.onActualChanged,
    required this.onAcknowledge,
  });

  static String _money(int value) =>
      '${value.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();

    return Obx(() {
      final actual = controller.actualOf(balance.wallet.id);
      final diff = actual - balance.bookBalance;
      final isBalanced = diff == 0;
      final isResolved = isBalanced || isAcknowledged;
      final isEditing = controller.editingWalletId.value == balance.wallet.id;
      final scheme = context.ccColorScheme;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isResolved
              ? scheme.primary.withValues(alpha: 0.06)
              : scheme.error.withValues(alpha: 0.06),
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
                    namedArgs: {'amount': _money(balance.bookBalance)},
                  ),
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CcText(
                  el.tr(CcLocaleKeys.reconciliation_actual),
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () => controller.startEditing(balance.wallet.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                        children: [
                          Expanded(
                            child: CcText(
                              '${TransactionFormHelpers.formatAmount(actual.toString())} đ',
                              textAlign: TextAlign.right,
                              textStyle: context.ccTextTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isEditing ? scheme.primary : null,
                                  ),
                            ),
                          ),
                          if (actual != 0) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (isEditing) {
                                  controller.clearAmount();
                                } else {
                                  controller.setActual(balance.wallet.id, 0);
                                }
                              },
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
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isResolved)
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: scheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  CcText(
                    el.tr(CcLocaleKeys.reconciliation_matched),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CcText(
                    el.tr(
                      CcLocaleKeys.reconciliation_lech,
                      namedArgs: {
                        'amount':
                            '${diff > 0 ? '+' : ''}${diff < 0 ? '-' : ''}${_money(diff.abs())}',
                      },
                    ),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
