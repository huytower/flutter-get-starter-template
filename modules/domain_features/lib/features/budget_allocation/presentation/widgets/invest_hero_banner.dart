import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

class InvestHeroBanner extends StatelessWidget {
  final WalletController walletController;
  final double topPadding;
  final double bottomPadding;
  final VoidCallback? onTap;

  const InvestHeroBanner({
    super.key,
    required this.walletController,
    this.topPadding = CcPaddingParams.SPACE_SM,
    this.bottomPadding = CcPaddingParams.SPACE_XS,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final color = scheme.investment;

    return CcPadding(
      CcBouncing(
        onTap: onTap,
        borderRadius: context.brXl,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: context.brXl,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: context.respDim(20),
                offset: Offset(0, context.respDim(10)),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
            vertical: context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CcText(
                      el.tr(CcLocaleKeys.wallet_investments),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: scheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                    const CcSpaceXS(),
                    Obx(
                      () => Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: scheme.onPrimary.withOpacity(0.8),
                            size: context.respIconSize(baseSize: 18),
                          ),
                          const SizedBox(width: 4),
                          CcText(
                            walletController.isBalanceVisible.value
                                ? TransactionFormHelpers.formatShort(
                                    walletController.investmentBalance.value,
                                  )
                                : '*********',
                            textStyle: context.ccTextTheme.headlineMedium
                                ?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: CcTypographyParams.bold,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const CcSpaceXS(),
                    CcText(
                      el.tr(CcLocaleKeys.wallet_investments_desc),
                      maxLines: 2,
                      textStyle: context.ccTextTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const CcSpaceSM(),
              _buildStats(context),
              const CcSpaceLG(),
              Container(
                padding: EdgeInsets.all(context.respDim(6)),
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CcIconToken(
                  Icons.trending_up_outlined,
                  color: scheme.onPrimary,
                  size: context.respIconSize(baseSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomPadding,
      CcPaddingParams.SPACE_LG,
      CcPaddingParams.SPACE_LG,
      topPadding,
    );
  }

  Widget _buildStats(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Obx(() {
      final roi = walletController.monthlyRoiPercent.value;
      final breakeven = walletController.monthlyBreakevenPercent.value;
      final invested = walletController.monthlyInvested.value;
      final returned = walletController.monthlyReturned.value;
      final visible = walletController.isBalanceVisible.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Period Indicator (Trending UX)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CcText(
              'Tháng ${DateTime.now().month}',
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: scheme.onPrimary,
                fontSize: context.respFontSize(8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _StatRow(
            label: 'ROI',
            value: '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%',
            color: scheme.onPrimary,
          ),
          const SizedBox(height: 2),
          _StatRow(
            label: el.tr(CcLocaleKeys.wallet_investment_breakeven),
            value: '${breakeven.toStringAsFixed(1)}%',
            color: scheme.onPrimary.withOpacity(0.9),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CompactIconStat(
                icon: Icons.eco,
                value: invested,
                visible: visible,
                color: scheme.onPrimary.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              _CompactIconStat(
                icon: Icons.auto_graph_rounded,
                value: returned,
                visible: visible,
                color: scheme.onPrimary,
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CcText(
          '$label: ',
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color.withOpacity(0.7),
            fontSize: context.respFontSize(10),
          ),
        ),
        CcText(
          value,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: CcTypographyParams.bold,
            fontSize: context.respFontSize(10),
          ),
        ),
      ],
    );
  }
}

class _CompactIconStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final bool visible;
  final Color color;

  const _CompactIconStat({
    required this.icon,
    required this.value,
    required this.visible,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: context.respIconSize(baseSize: 10),
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 2),
        CcText(
          visible ? TransactionFormHelpers.formatShort(value) : '***',
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: CcTypographyParams.bold,
            fontSize: context.respFontSize(9),
          ),
        ),
      ],
    );
  }
}
