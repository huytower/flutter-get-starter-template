import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/currency/money_formatter.dart';
import '../../../../core/di/di.dart';
import '../../../wallet/domain/entities/wallet_balance_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../../wallet/presentation/widgets/wallet_display_name.dart';
import '../get_x/reconciliation_controller.dart';
import 'wallet_actual_balance_input.dart';
import 'wallet_reconcile_status_row.dart';

class WalletReconcileTile extends StatelessWidget {
  final WalletBalanceEntity balance;
  final ValueChanged<int> onActualChanged;
  final VoidCallback onAcknowledge;
  final VoidCallback onReview;

  const WalletReconcileTile({
    super.key,
    required this.balance,
    required this.onActualChanged,
    required this.onAcknowledge,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());

    final stacked = CcTwoColumn.shouldUse(context);

    return Obx(() {
      final currencyCode = walletController.currencyCode.value;
      final counted = controller.actualOf(balance.wallet.id);
      final hasCounted = counted != null;
      final actual = counted ?? balance.bookBalance;
      final diff = actual - balance.bookBalance;
      final hasBalanced = diff == 0;
      final hasAcknowledged = controller.hasAcknowledged(balance.wallet.id);
      final hasResolved = hasBalanced || hasAcknowledged;
      final hasEditing = controller.editingWalletId.value == balance.wallet.id;
      final scheme = context.ccColorScheme;

      Widget actualInput() => WalletActualBalanceInput(
        actual: counted,
        hasEditing: hasEditing,
        currencyCode: currencyCode,
        onTap: () => controller.startEditing(balance.wallet.id),
        onClear: () {
          if (hasEditing) {
            controller.clearAmount();
          } else {
            controller.resetActual(balance.wallet.id);
          }
        },
      );

      // Not counted yet: neutral, never an error — the wallet is assumed to
      // match its book balance until the user enters a counted amount.
      final statusColor = !hasCounted
          ? scheme.onSurfaceVariant
          : hasResolved
          ? scheme.primary
          : scheme.error;

      // Keeps the tile above the money keypad while its amount is edited.
      return CcScrollIntoView(
        hasActive: hasEditing,
        child: Container(
          margin: EdgeInsets.only(
            bottom: context.respDim(CcPaddingParams.SPACE_MD),
          ),
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: context.brLg,
            border: Border.all(
              color: hasEditing
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.4),
              width: hasEditing ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.10),
                blurRadius: context.respDim(12),
                offset: Offset(0, context.respDim(4)),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CcText(
                    balance.wallet.displayName(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                      fontWeight: CcTypographyParams.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const CcSpaceSM(),
                  if (stacked) ...[
                    // Landscape tablet: two rows — "Book" + amount, then
                    // "Actual" + amount — so each amount has the full width.
                    _buildBookColumn(context, scheme, currencyCode),
                    const CcSpaceSM(),
                    actualInput(),
                  ] else
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildBookColumn(context, scheme, currencyCode),
                          const CcSpaceSM(),
                          Expanded(child: actualInput()),
                        ],
                      ),
                    ),
                  const CcSpaceSM(),
                  WalletReconcileStatusRow(
                    hasCounted: hasCounted,
                    hasBalanced: hasBalanced,
                    hasAcknowledged: hasAcknowledged,
                    diff: diff,
                    currencyCode: currencyCode,
                    statusColor: statusColor,
                    onAcknowledge: onAcknowledge,
                    onReview: onReview,
                    stacked: stacked,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Left half of the comparison row: the book balance.
  Widget _buildBookColumn(
    BuildContext context,
    ColorScheme scheme,
    String currencyCode,
  ) {
    return Row(
      children: [
        CcText(
          el.tr(PrjLocaleKeys.reconciliation_book),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const CcSpaceSM(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: CcText(
            formatCurrencyWithSymbol(
              balance.bookBalance,
              currencyCode: currencyCode,
            ),
            maxLines: 1,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
