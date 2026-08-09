import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Hero banner displaying a specific asset category with its balance.
class BudgetHeroBanner extends StatelessWidget {
  const BudgetHeroBanner({
    required this.walletController,
    required this.titleKey,
    required this.balance,
    required this.subtitleKey,
    required this.icon,
    required this.color,
    this.subtitleArgs,
    this.topPadding = CcPaddingParams.SPACE_LG,
    this.bottomPadding = CcPaddingParams.SPACE_SM,
    this.onTap,
    super.key,
  });

  final WalletController walletController;
  final String titleKey;
  final RxInt balance;
  final String subtitleKey;

  /// Interpolated into [subtitleKey] via `el.tr`'s `namedArgs` (e.g. a live
  /// ROI percentage). Null for banners with a plain, static subtitle.
  final Map<String, String>? subtitleArgs;
  final IconData icon;
  final Color color;
  final double topPadding;
  final double bottomPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(topPadding),
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(bottomPadding),
      ),
      child: GestureDetector(
        onTap: onTap,
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
                      el.tr(titleKey),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: scheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                    const CcSpaceXS(),
                    Obx(
                      () => CcText(
                        walletController.isBalanceVisible.value
                            ? '${balance.value.formatShort()} đ'
                            : '*********',
                        textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: CcTypographyParams.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const CcSpaceXS(),
                    CcText(
                      el.tr(subtitleKey, namedArgs: subtitleArgs),
                      maxLines: 2,
                      textStyle: context.ccTextTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const CcSpaceLG(),
              Container(
                padding: EdgeInsets.all(context.respDim(10)),
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CcIconToken(
                  icon,
                  color: scheme.onPrimary,
                  size: context.respIconSize(baseSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
