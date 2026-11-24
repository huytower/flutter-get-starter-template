import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/get_x/prj_get_view.dart';
import '../../../guideline/export_guideline.dart';
import '../../../transaction/domain/usecases/create_wallet_transfer_usecase.dart';
import '../get_x/wallet_controller.dart';
import '../get_x/wallet_sheets.dart';
import '../widgets/liquid_wallet_list_item.dart';
import '../widgets/transfer_money_sheet.dart';

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
    controller.hasEditMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return _LiquidWalletListView(controller: controller);
  }
}

class _LiquidWalletListView extends PrjGetView<WalletController> {
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
            controller.hasEditMode.value
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
          el.tr(PrjLocaleKeys.wallet_your_wallets),
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
          tooltip: el.tr(PrjLocaleKeys.wallet_add_title),
          onTap: () => controller.openForm(context),
        ),
        Obx(() {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CcIconButton.bouncing(
                onTap: controller.toggleEditMode,
                tooltip: controller.hasEditMode.value
                    ? el.tr(PrjLocaleKeys.common_done)
                    : el.tr(PrjLocaleKeys.common_edit),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    controller.hasEditMode.value
                        ? Icons.check_circle_outline_rounded
                        : Icons.tune_rounded,
                    key: ValueKey(controller.hasEditMode.value),
                    color: context.ccColorScheme.onPrimary,
                    size: context.respIconSize(baseSize: 24),
                  ),
                ),
              ),
              if (getIt<GuidelineProvider>().hasAvailable)
                Obx(() {
                  final guideline = getIt<GuidelineProvider>();
                  final showing =
                      guideline.hasTaskActive('wallet_balance') &&
                      !controller.hasEditMode.value;
                  return Positioned(
                    bottom: context.respDim(-10),
                    right: context.respDim(-10),
                    child: PrjGuidelineBadge(
                      showing: showing,
                      size: context.respDim(10),
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
      final hasEdit = controller.hasEditMode.value;

      if (liquidWallets.isEmpty) {
        return CcText(
          el.tr(PrjLocaleKeys.wallet_empty),
          align: Alignment.center,
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
          ),
        );
      }

      final items = [
        for (final wallet in liquidWallets)
          LiquidWalletListItem(
            wallet: wallet,
            hasEditMode: hasEdit,
            canDelete: controller.canDeleteWallet(wallet),
            onEdit: () => controller.openForm(context, wallet: wallet),
            onDelete: () => controller.confirmDelete(context, wallet),
            onTransfer: () => TransferMoneySheet.show(
              context,
              sourceWallet: wallet,
              transfer: getIt<CreateWalletTransferUseCase>(),
            ),
          ),
      ];

      return PopScope(
        canPop: !controller.hasEditMode.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // Page popped normally, ensure edit mode is reset for next entry.
            controller.hasEditMode.value = false;
            return;
          }
          // If we are here, didPop is false, which means pop was blocked by canPop: false.
          // This happens when isEditMode is true.
          if (controller.hasEditMode.value) {
            controller.hasEditMode.value = false;
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Small tablet and up (>= 600 dp, either orientation): wallets
            // flow across two columns instead of one stretched row each.
            final useGrid = CcWindowSizeClass.fromWidth(
              constraints.maxWidth,
            ).hasAtLeast(CcWindowSizeClass.medium);
            return ListView(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.SPACE_MD),
              ),
              children: [
                if (useGrid)
                  CcMaxWidth(
                    maxWidth: CcTwoColumn.defaultMaxWidth,
                    child: CcMultiColumn(
                      columns: 2,
                      columnGap: context.respPadding(CcPaddingParams.SPACE_MD),
                      children: items,
                    ),
                  )
                else
                  ...items,
              ],
            );
          },
        ),
      );
    });
  }
}
