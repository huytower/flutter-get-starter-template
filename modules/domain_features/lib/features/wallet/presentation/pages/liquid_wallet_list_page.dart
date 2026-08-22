import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../guideline/guideline_controller.dart';
import '../get_x/wallet_controller.dart';
import '../widgets/liquid_wallet_list_item.dart';

@RoutePage()
class LiquidWalletListPage extends CcGetView<WalletController> {
  const LiquidWalletListPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      leading: Obx(
        () => CcIconButton.bouncing(
          icon: Icon(
            controller.isEditMode.value
                ? Icons.close_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          onTap: () => controller.onCloseEditMode(context),
        ),
      ),
      title: Center(
        child: CcText(
          el.tr(CcLocaleKeys.wallet_your_wallets),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          icon: Icon(
            Icons.add,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          tooltip: el.tr(CcLocaleKeys.wallet_add_title),
          onTap: () => controller.openForm(context),
        ),
        Obx(() {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CcIconButton.bouncing(
                onTap: controller.toggleEditMode,
                tooltip: controller.isEditMode.value
                    ? el.tr(CcLocaleKeys.common_done)
                    : el.tr(CcLocaleKeys.common_edit),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    controller.isEditMode.value
                        ? Icons.check_circle_outline_rounded
                        : Icons.tune_rounded,
                    key: ValueKey(controller.isEditMode.value),
                    color: context.ccColorScheme.onPrimary,
                    size: context.respIconSize(baseSize: 24),
                  ),
                ),
              ),
              if (Get.isRegistered<GuidelineController>())
                Obx(() {
                  final guideline = Get.find<GuidelineController>();
                  final showing =
                      guideline.isTaskActive('wallet_balance') &&
                      !controller.isEditMode.value;
                  return Positioned(
                    top: 0,
                    right: 0,
                    child: CcGuidelineBadge(
                      showing: showing,
                      color: guideline.currentColor,
                      bounceTrigger: guideline.bounceTrigger,
                      size: 10,
                    ),
                  );
                }),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    final liquidWallets = controller.liquidWallets;
    if (liquidWallets.isEmpty) {
      return CcText(
        el.tr(CcLocaleKeys.wallet_empty),
        align: Alignment.center,
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
        ),
      );
    }
    final isEdit = controller.isEditMode.value;
    return ListView(
      padding: EdgeInsets.all(
        context.respPadding(CcPaddingParams.SPACE_MD),
      ),
      children: liquidWallets
          .map(
            (wallet) => LiquidWalletListItem(
              wallet: wallet,
              isEditMode: isEdit,
              canDelete: controller.canDeleteWallet(wallet),
              onEdit: () => controller.openForm(context, wallet: wallet),
              onDelete: () => controller.confirmDelete(context, wallet),
            ),
          )
          .toList(),
    );
  }
}
