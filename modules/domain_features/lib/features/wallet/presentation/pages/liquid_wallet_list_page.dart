import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../guideline/export_guideline.dart';
import '../get_x/wallet_controller.dart';
import '../widgets/liquid_wallet_list_item.dart';

@RoutePage()
class LiquidWalletListPage extends StatefulWidget {
  const LiquidWalletListPage({super.key});

  @override
  State<LiquidWalletListPage> createState() => _LiquidWalletListPageState();
}

class _LiquidWalletListPageState extends State<LiquidWalletListPage> {
  late final WalletController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WalletController>();
    // Ensure edit mode is always off when entering the page.
    controller.isEditMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return _LiquidWalletListView(controller: controller);
  }
}

class _LiquidWalletListView extends CcGetView<WalletController> {
  const _LiquidWalletListView({required this.controller});

  @override
  final WalletController controller;

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
                    bottom: -10,
                    right: -10,
                    child: PrjGuidelineBadge(
                      showing: showing,
                      size: 10,
                      label: null,
                      growRight: false,
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
    return Obx(() {
      final liquidWallets = controller.liquidWallets;
      final isEdit = controller.isEditMode.value;

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

      return PopScope(
        canPop: !controller.isEditMode.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // Page popped normally, ensure edit mode is reset for next entry.
            controller.isEditMode.value = false;
            return;
          }
          // If we are here, didPop is false, which means pop was blocked by canPop: false.
          // This happens when isEditMode is true.
          if (controller.isEditMode.value) {
            controller.isEditMode.value = false;
          }
        },
        child: ListView(
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
        ),
      );
    });
  }
}
