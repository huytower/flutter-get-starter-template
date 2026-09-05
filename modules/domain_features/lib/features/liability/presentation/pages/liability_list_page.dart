import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../get_x/liability_list_controller.dart';
import '../widgets/add_liability_sheet.dart';
import '../widgets/liability_delete_confirm_sheet.dart';
import '../widgets/liability_wallet_grid_card.dart';

@RoutePage()
class LiabilityListPage extends StatefulWidget {
  const LiabilityListPage({super.key});

  @override
  State<LiabilityListPage> createState() => _LiabilityListPageState();
}

class _LiabilityListPageState extends State<LiabilityListPage> {
  late final LiabilityListController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LiabilityListController>()) {
      Get.put(getIt<LiabilityListController>(), permanent: true);
    }
    controller = Get.find<LiabilityListController>();
    // Ensure edit mode is always off when entering the page.
    controller.isEditMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return _LiabilityListView(controller: controller);
  }
}

class _LiabilityListView extends CcGetView<LiabilityListController> {
  const _LiabilityListView({required this.controller});

  @override
  final LiabilityListController controller;

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
        el.tr(CcLocaleKeys.liability_list_title),
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
          onTap: () => _openAddLiability(context),
        ),
        Obx(() {
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
      final balances = controller.loans.toList();
      final isEdit = controller.isEditMode.value;

      if (balances.isEmpty) {
        return CcText(
          el.tr(CcLocaleKeys.liability_empty_state),
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
        child: GridView.builder(
          padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_XS)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
            mainAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
          ),
          itemCount: balances.length,
          itemBuilder: (context, index) {
            final balance = balances[index];
            return LiabilityWalletGridCard(
              key: ValueKey(balance.liability.id),
              balance: balance,
              isEditMode: isEdit,
              canDelete: true,
              onEdit: () => _openAddLiability(context),
              onDelete: () => _confirmDelete(context, balance.liability.id),
            );
          },
        ),
      );
    });
  }

  Future<void> _openAddLiability(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddLiabilitySheet(),
    );
    if (created == true) {
      controller.load();
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LiabilityDeleteConfirmSheet(
        liability: controller.loans
            .firstWhere((b) => b.liability.id == id)
            .liability,
        onDelete: () => controller.deleteLiability(context, id),
      ),
    );
  }
}
