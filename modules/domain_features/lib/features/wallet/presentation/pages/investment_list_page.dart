import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/presentation/widgets/edit_badge.dart';
import '../get_x/wallet_controller.dart';
import '../widgets/add_investment_sheet.dart';
import '../widgets/investment_wallet_list_item.dart';

@RoutePage()
class InvestmentListPage extends StatefulWidget {
  const InvestmentListPage({super.key});

  @override
  State<InvestmentListPage> createState() => _InvestmentListPageState();
}

class _InvestmentListPageState extends State<InvestmentListPage> {
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
    return _InvestmentListView(controller: controller);
  }
}

class _InvestmentListView extends CcGetView<WalletController> {
  const _InvestmentListView({required this.controller});

  @override
  final WalletController controller;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
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
      title: CcText(
        el.tr(CcLocaleKeys.wallet_investments),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          fontWeight: CcTypographyParams.bold,
          color: context.ccColorScheme.onPrimary,
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          icon: Icon(
            Icons.add_circle_outline_rounded,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          onTap: () => _openAddInvestment(context),
        ),
        Obx(() {
          if (!controller.isVip.value) return const SizedBox.shrink();

          return CcIconButton.bouncing(
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
          );
        }),
        SizedBox(width: context.respPadding(CcPaddingParams.SPACE_SM)),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      final wallets = controller.investmentWallets;
      final isEdit = controller.isEditMode.value;

      if (wallets.isEmpty) {
        return CcText(
          el.tr(CcLocaleKeys.wallet_investment_empty),
          align: Alignment.center,
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        );
      }

      return PopScope(
        canPop: !controller.isEditMode.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            controller.isEditMode.value = false;
            return;
          }
          if (controller.isEditMode.value) {
            controller.isEditMode.value = false;
          }
        },
        child: ReorderableListView.builder(
          onReorder: controller.reorderInvestments,
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) => ScaleTransition(
            scale: animation.drive(Tween(begin: 1.0, end: 0.9)),
            child: Material(color: Colors.transparent, child: child),
          ),
          padding: EdgeInsets.only(
            left: context.respPadding(CcPaddingParams.PAGE_SM),
            right: context.respPadding(CcPaddingParams.PAGE_SM),
            top: context.respPadding(CcPaddingParams.SPACE_MD),
            bottom: context.respDim(100),
          ),
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            final stats = controller.investmentStatsOf(wallet.id);
            return InvestmentWalletListItem(
              key: ValueKey(wallet.id),
              wallet: wallet,
              contributed: stats.contributed,
              returned: stats.returned,
              isEditMode: isEdit,
              canDelete: controller.canDeleteWallet(wallet),
              onEdit: () => _openAddInvestment(context, wallet: wallet),
              onDelete: () => controller.confirmDelete(context, wallet),
              dragHandle: isEdit
                  ? ReorderableDragStartListener(
                      index: index,
                      child: EditBadge(
                        icon: Icons.drag_indicator,
                        color: context.ccColorScheme.surfaceContainerHighest,
                        foregroundColor: context.ccColorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            );
          },
        ),
      );
    });
  }

  void _openAddInvestment(BuildContext context, {dynamic wallet}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddInvestmentSheet(wallet: wallet),
    );
  }
}
