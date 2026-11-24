import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/get_x/prj_get_view.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../get_x/liability_list_controller.dart';
import '../widgets/add_liability_sheet.dart';
import '../widgets/lend_wallet_list_item.dart';

@RoutePage()
class LendListPage extends StatefulWidget {
  const LendListPage({super.key, this.openAddOnStart = false});

  /// Opens the "add lend" sheet as soon as the page is shown (e.g. when
  /// coming from the Lend form's customize cell).
  final bool openAddOnStart;

  /// Pushes the page, optionally with the "add lend" sheet open.
  static Future<void> open(BuildContext context, {bool openAdd = false}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LendListPage(openAddOnStart: openAdd),
      ),
    );
  }

  @override
  State<LendListPage> createState() => _LendListPageState();
}

class _LendListPageState extends State<LendListPage> {
  late final LiabilityListController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LiabilityListController>()) {
      Get.put(getIt<LiabilityListController>(), permanent: true);
    }
    controller = Get.find<LiabilityListController>();
    controller.hasEditMode.value = false;

    if (widget.openAddOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openAddLendSheet(context, controller);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LendListView(controller: controller);
  }
}

class _LendListView extends PrjGetView<LiabilityListController> {
  const _LendListView({required this.controller});

  @override
  final LiabilityListController controller;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
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
      title: CcText(
        el.tr(PrjLocaleKeys.liability_lend),
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
          onTap: () => _openAddLend(context),
        ),
        Obx(() {
          return CcIconButton.bouncing(
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
          );
        }),
        const CcSpaceSM(),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      final balances = controller.lendBalances;
      final hasEdit = controller.hasEditMode.value;

      if (balances.isEmpty) {
        return CcText(
          el.tr(PrjLocaleKeys.liability_empty_state_v2),
          align: Alignment.center,
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        );
      }

      Widget buildItem(LiabilityBalanceEntity balance, bool hasEdit) =>
          LendWalletListItem(
            key: ValueKey(balance.liability.id),
            balance: balance,
            hasEditMode: hasEdit,
            canDelete: true,
            onEdit: () => _openAddLend(context),
            onDelete: () => _confirmDelete(context, balance.liability.id),
          );

      return PopScope(
        canPop: !controller.hasEditMode.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            controller.hasEditMode.value = false;
            return;
          }
          if (controller.hasEditMode.value) {
            controller.hasEditMode.value = false;
          }
        },
        child: CcTwoColumn.shouldUse(context)
            // Landscape tablet: three columns instead of one stretched list.
            ? ListView(
                padding: EdgeInsets.all(
                  context.respPadding(CcPaddingParams.PAGE_SM),
                ),
                children: [
                  CcMaxWidth(
                    maxWidth: CcTwoColumn.defaultMaxWidth,
                    child: CcMultiColumn(
                      rowGap: context.respPadding(CcPaddingParams.SPACE_SM),
                      children: [
                        for (final balance in balances)
                          buildItem(balance, hasEdit),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: EdgeInsets.all(
                  context.respPadding(CcPaddingParams.PAGE_SM),
                ),
                itemCount: balances.length,
                separatorBuilder: (context, index) => const CcSpaceSM(),
                itemBuilder: (context, index) =>
                    buildItem(balances[index], hasEdit),
              ),
      );
    });
  }

  Future<void> _openAddLend(BuildContext context) =>
      _openAddLendSheet(context, controller);

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await CcConfirmSheet.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: el.tr(PrjLocaleKeys.liability_delete_title),
      message: el.tr(PrjLocaleKeys.liability_delete_confirm_msg),
      confirmLabel: el.tr(PrjLocaleKeys.common_delete),
    );
    if (!confirmed || !context.mounted) return;
    await controller.deleteLiability(context, id);
  }
}

Future<void> _openAddLendSheet(
  BuildContext context,
  LiabilityListController controller,
) async {
  final created = await AddLiabilitySheet.show(
    context,
    initialDirection: LiabilityDirection.lend,
    showDirectionToggle: false,
  );
  if (created == true) {
    controller.load();
  }
}
