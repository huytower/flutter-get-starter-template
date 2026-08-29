import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import 'compact_stat_row.dart';
import 'invest_period_indicator.dart';

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
                          CcIcon(
                            icon: Icons.eco,
                            size: context.respIconSize(baseSize: 18),
                            color: scheme.onPrimary.withOpacity(0.8),
                          ),
                          CcText(
                            walletController.isBalanceVisible.value
                                ? TransactionFormHelpers.formatShort(
                                    walletController.investmentBalance.value,
                                  )
                                : '*********',
                            textStyle: context.ccTextTheme.headlineSmall
                                ?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: CcTypographyParams.bold,
                                  letterSpacing: 0.2,
                                ),
                          ),
                          const CcSpaceSM(),
                          Icon(
                            Icons.auto_graph_rounded,
                            color: scheme.onPrimary.withOpacity(0.8),
                            size: context.respIconSize(baseSize: 16),
                          ),
                          CcText(
                            walletController.isBalanceVisible.value
                                ? TransactionFormHelpers.formatShort(
                                    walletController.investmentBalance.value,
                                  )
                                : '*********',
                            textStyle: context.ccTextTheme.headlineSmall
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
              const CcSpaceXS(),
              _buildStats(context),
              const CcSpaceXS(),
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Period Indicator (Trending UX)
          InvestPeriodIndicator(
            month: DateTime.now().month,
            color: scheme.onPrimary,
          ),
          const SizedBox(height: 6),
          CompactStatRow(
            label: 'ROI',
            value: '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%',
            color: scheme.onPrimary,
          ),
          const SizedBox(height: 2),
          CompactStatRow(
            label: el.tr(CcLocaleKeys.wallet_investment_breakeven),
            value: '${breakeven.toStringAsFixed(1)}%',
            color: scheme.onPrimary.withOpacity(0.9),
          ),
          const SizedBox(height: 6),
        ],
      );
    });
  }
}
