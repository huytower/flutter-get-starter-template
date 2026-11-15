import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../wallet/domain/entities/wallet_balance_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../../wallet/presentation/widgets/wallet_display_name.dart';
import '../get_x/reconciliation_controller.dart';

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

    return Obx(() {
      final currencyCode = walletController.currencyCode.value;
      final counted = controller.actualOf(balance.wallet.id);
      final isCounted = counted != null;
      final actual = counted ?? balance.bookBalance;
      final diff = actual - balance.bookBalance;
      final isBalanced = diff == 0;
      final isAcknowledged = controller.isAcknowledged(balance.wallet.id);
      final isResolved = isBalanced || isAcknowledged;
      final isEditing = controller.editingWalletId.value == balance.wallet.id;
      final scheme = context.ccColorScheme;

      // Not counted yet: neutral, never an error — the wallet is assumed to
      // match its book balance until the user enters a counted amount.
      final statusColor = !isCounted
          ? scheme.onSurfaceVariant
          : isResolved
          ? scheme.primary
          : scheme.error;

      return Container(
        margin: EdgeInsets.only(
          bottom: context.respDim(CcPaddingParams.SPACE_MD),
        ),
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: context.brLg,
          border: Border.all(
            color: isEditing
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.4),
            width: isEditing ? 2 : 1,
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
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBookColumn(context, scheme, currencyCode),
                      ),
                      VerticalDivider(
                        width: context.respDim(24),
                        thickness: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                      Expanded(
                        child: WalletActualBalanceInput(
                          actual: counted,
                          isEditing: isEditing,
                          currencyCode: currencyCode,
                          onTap: () =>
                              controller.startEditing(balance.wallet.id),
                          onClear: () {
                            if (isEditing) {
                              controller.clearAmount();
                            } else {
                              controller.resetActual(balance.wallet.id);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const CcSpaceSM(),
                WalletReconcileStatusRow(
                  isCounted: isCounted,
                  isBalanced: isBalanced,
                  isAcknowledged: isAcknowledged,
                  diff: diff,
                  currencyCode: currencyCode,
                  statusColor: statusColor,
                  onAcknowledge: onAcknowledge,
                  onReview: onReview,
                ),
              ],
            ),
            _buildGuidelineBadge(context),
          ],
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
          el.tr(CcLocaleKeys.reconciliation_book),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: FittedBox(
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
        ),
      ],
    );
  }

  Widget _buildGuidelineBadge(BuildContext context) {
    return const SizedBox();
  }
}

class WalletActualBalanceInput extends StatelessWidget {
  /// Counted amount, or null while the wallet has not been counted yet.
  final int? actual;
  final bool isEditing;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const WalletActualBalanceInput({
    super.key,
    required this.actual,
    required this.isEditing,
    required this.currencyCode,
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
        const CcSpaceSM(),
        Expanded(
          child: CcBouncing(
            onTap: onTap,
            borderRadius: context.brMd,
            child: Container(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.SPACE_SM),
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: context.brMd,
                border: Border.all(
                  color: isEditing
                      ? scheme.primary
                      : scheme.outline.withValues(alpha: 0.5),
                  width: isEditing ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: CcText(
                        actual == null
                            ? el.tr(CcLocaleKeys.reconciliation_not_counted)
                            : formatCurrencyWithSymbol(
                                actual!,
                                currencyCode: currencyCode,
                              ),
                        maxLines: 1,
                        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                          fontWeight: actual == null
                              ? CcTypographyParams.regular
                              : CcTypographyParams.bold,
                          color: isEditing
                              ? scheme.primary
                              : actual == null
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  if (actual != null) ...[
                    const CcSpaceXS(),
                    CcBouncing(
                      onTap: onClear,
                      child: Icon(
                        Icons.cancel,
                        size: context.respIconSize(baseSize: 16),
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WalletReconcileStatusRow extends StatelessWidget {
  final bool isCounted;
  final bool isBalanced;
  final bool isAcknowledged;
  final int diff;
  final String currencyCode;
  final Color statusColor;
  final VoidCallback onAcknowledge;
  final VoidCallback onReview;

  const WalletReconcileStatusRow({
    super.key,
    required this.isCounted,
    required this.isBalanced,
    required this.isAcknowledged,
    required this.diff,
    required this.currencyCode,
    required this.statusColor,
    required this.onAcknowledge,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    if (!isCounted) {
      return Row(
        children: [
          Icon(
            Icons.radio_button_unchecked_rounded,
            size: context.respIconSize(baseSize: 16),
            color: scheme.onSurfaceVariant,
          ),
          const CcSpaceXS(),
          CcText(
            el.tr(CcLocaleKeys.reconciliation_not_counted),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

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
                      '${diff > 0 ? '+' : ''}${diff < 0 ? '-' : ''}${formatCurrencyWithSymbol(diff.abs(), currencyCode: currencyCode)}',
                },
              ),
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAcknowledged)
              CcBouncing(
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
            CcIconButton.bouncing(
              icon: Icon(
                Icons.fact_check_outlined,
                size: context.respIconSize(baseSize: 16),
                color: scheme.onSurfaceVariant,
              ),
              height: context.respDim(28),
              width: context.respDim(28),
              tooltip: el.tr(CcLocaleKeys.reconciliation_review_transactions),
              onTap: onReview,
            ),
          ],
        ),
      ],
    );
  }
}
