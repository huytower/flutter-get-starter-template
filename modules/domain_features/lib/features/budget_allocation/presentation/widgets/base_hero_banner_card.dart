import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/presentation/helper/transaction_form_helpers.dart';
import '../get_x/budget_allocation_controller.dart';

/// Base reusable widget for Hero Banner cards (Liability, Investment, etc.).
/// Enforces glassmorphic design for back cards and solid priority for front cards.
class BaseHeroBannerCard extends StatelessWidget {
  const BaseHeroBannerCard({
    required this.titleKey,
    required this.balance,
    required this.subtitleKey,
    required this.balanceIcon,
    this.bannerIcon,
    this.bannerIconAsset,
    required this.color,
    required this.hasFront,
    this.onTap,
    super.key,
  });

  final String titleKey;
  final int balance;
  final String subtitleKey;
  final IconData balanceIcon;
  final IconData? bannerIcon;
  final String? bannerIconAsset;
  final Color color;
  final bool hasFront;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetAllocationController>();
    final walletController = controller.walletController;

    return Obx(
      () => CcHeroBannerCard(
        title: el.tr(titleKey),
        formattedValue: walletController.hasBalanceVisible.value
            ? TransactionFormHelpers.formatShortWithSymbol(
                balance,
                currencyCode: walletController.currencyCode.value,
              )
            : '*********',
        subtitle: el.tr(subtitleKey),
        valueIcon: balanceIcon,
        bannerIcon: bannerIcon,
        bannerIconAsset: bannerIconAsset,
        color: color,
        hasFront: hasFront,
        onTap: onTap,
        onSwap: controller.toggleLiabilityCardStack,
      ),
    );
  }
}
