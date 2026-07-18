import 'package:auto_route/annotations.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/gradient_app_bar.dart';
import '../../../../core/util/money_format_helper.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';

@RoutePage()
class WalletDetailPage extends StatelessWidget with CcViewConfigMixin {
  final WalletEntity wallet;

  const WalletDetailPage({super.key, required this.wallet});

  /// Current (book) balance from the live controller; falls back to the opening
  /// balance if the wallet list controller is no longer in memory.
  int get _currentBalance => Get.isRegistered<WalletController>()
      ? Get.find<WalletController>().bookBalanceOf(wallet.id)
      : wallet.balance;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      leading: CcIconButton.bouncing(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
        onTap: () => Navigator.of(context).pop(),
      ),
      title: Center(
        child: CcText(
          wallet.name,
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold
          ),
        ),
      ),
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Builder(
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
            vertical: context.respPadding(CcPaddingParams.PAGE_LG),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(context),
              const CcSpaceXL(),
              _buildMetaData(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.ccColorScheme.primary,
            context.ccColorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.wallet_total_assets),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onPrimary.withOpacity(0.8)
            ),
          ),
          const CcSpaceMD(),
          CcText(
            formatVndWithSymbol(_currentBalance),
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaData(BuildContext context) {
    return CcResponsiveFlex(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoChip(
          context,
          label: 'Wallet ID',
          value: wallet.id,
          icon: Icons.fingerprint,
        ),
        _buildInfoChip(
          context,
          label: 'Type',
          value: wallet.type,
          icon: Icons.category,
        ),
        _buildInfoChip(
          context,
          label: 'Created',
          value:
              '${wallet.createdAt.day}/${wallet.createdAt.month}/${wallet.createdAt.year}',
          icon: Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: CcWidgetHelper.getBorderRoundedSM(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CcIconToken(icon, size: 16),
          const CcSpaceXS(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CcText(
                label,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ),
              CcText(
                value,
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
