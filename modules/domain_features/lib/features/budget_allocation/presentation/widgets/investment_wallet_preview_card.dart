import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Compact horizontal card for an investment asset shown on the dashboard.
class InvestmentWalletPreviewCard extends StatelessWidget {
  const InvestmentWalletPreviewCard({
    required this.wallet,
    required this.onMore,
    required this.onTap,
    super.key,
  });

  final WalletEntity wallet;
  final VoidCallback onMore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final controller = Get.find<WalletController>();
    final stats = controller.investmentStatsOf(wallet.id);

    return CcInkWell(
      onTap: onTap,
      onLongPress: onMore,
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          Container(
            width: context.respDim(160),
            padding: EdgeInsets.symmetric(
              horizontal: context.respDim(12),
              vertical: context.respDim(8),
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: context.brLg,
              border: Border.all(
                color: scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: context.respDim(28),
                      height: context.respDim(28),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.12),
                        borderRadius: context.brLg,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned.fill(child: CcGlassyGradientIcon()),
                          CcIconToken(
                            iconDataFromCode(wallet.iconCode),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    const CcSpaceSM(),
                    Expanded(
                      child: CcText(
                        wallet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textStyle: context.ccTextTheme.labelMedium?.copyWith(
                          fontWeight: CcTypographyParams.bold,
                          color: scheme.onSurface,
                          fontSize: context.respFontSize(11),
                        ),
                      ),
                    ),
                  ],
                ),
                const CcSpaceXS(),
                Divider(color: scheme.onSurface.withOpacity(0.06), height: 1),
                const CcSpaceXS(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCompactStat(
                      context,
                      icon: Icons.auto_graph_rounded,
                      color: PrjColors.success,
                      value: stats.returned,
                    ),
                    _buildCompactStat(
                      context,
                      icon: Icons.eco,
                      color: scheme.onSurfaceVariant,
                      value: stats.contributed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int value,
  }) {
    final controller = Get.find<WalletController>();

    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: context.respIconSize(baseSize: 12),
            color: color.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          CcText(
            controller.isBalanceVisible.value
                ? TransactionFormHelpers.formatShort(value)
                : '*****',
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: CcTypographyParams.semiBold,
              fontSize: context.respFontSize(10),
            ),
          ),
        ],
      ),
    );
  }
}
