import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/get_x/prj_get_view.dart';
import '../../../../core/presentation/helper/adaptive_bottom_sheet.dart';
import '../get_x/wallet_controller.dart';
import '../get_x/wallet_sheets.dart';
import '../widgets/add_investment_sheet.dart';
import '../widgets/investment_wallet_list_item.dart';

@RoutePage()
class InvestmentListPage extends StatefulWidget {
  const InvestmentListPage({super.key, this.openAddOnStart = false});

  /// Opens the "add investment" sheet as soon as the page is shown (e.g. when
  /// coming from the Investment form's customize cell).
  final bool openAddOnStart;

  /// Pushes the page, optionally with the "add investment" sheet open.
  static Future<void> open(BuildContext context, {bool openAdd = false}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InvestmentListPage(openAddOnStart: openAdd),
      ),
    );
  }

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

    if (widget.openAddOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAddInvestmentSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InvestmentListView(controller: controller);
  }
}

class _InvestmentListView extends PrjGetView<WalletController> {
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
        el.tr(PrjLocaleKeys.wallet_investments),
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
                ? el.tr(PrjLocaleKeys.common_done)
                : el.tr(PrjLocaleKeys.common_edit),
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
          el.tr(PrjLocaleKeys.wallet_investment_empty),
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
            return SizedBox(
              key: ValueKey(wallet.id),
              child: Obx(() {
                final stats = controller.investmentStatsOf(wallet.id);
                return InvestmentWalletListItem(
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
                          child: CcEditBadge(
                            icon: Icons.drag_indicator,
                            color:
                                context.ccColorScheme.surfaceContainerHighest,
                            foregroundColor:
                                context.ccColorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                );
              }),
            );
          },
        ),
      );
    });
  }

  void _openAddInvestment(BuildContext context, {dynamic wallet}) =>
      _showAddInvestmentSheet(context, wallet: wallet);
}

void _showAddInvestmentSheet(BuildContext context, {dynamic wallet}) {
  showAdaptiveBottomSheet<void>(
    context: context,
    backgroundColor: context.ccColorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddInvestmentSheet(wallet: wallet),
  );
}
