import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/getx/cc_get_view.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import '../get_x/liability_list_controller.dart';
import '../widgets/add_liability_sheet.dart';
import '../widgets/liability_delete_confirm_sheet.dart';
import '../widgets/liability_wallet_grid_card.dart';
import '../../../../core/helper/adaptive_bottom_sheet.dart';

@RoutePage()
class LiabilityGridPage extends StatefulWidget {
  const LiabilityGridPage({super.key, this.openAddOnStart = false});

  /// Opens the "add liability" sheet as soon as the page is shown (e.g. when
  /// coming from the Liability form's customize cell).
  final bool openAddOnStart;

  /// Pushes the page, optionally with the "add liability" sheet open.
  static Future<void> open(BuildContext context, {bool openAdd = false}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiabilityGridPage(openAddOnStart: openAdd),
      ),
    );
  }

  @override
  State<LiabilityGridPage> createState() => _LiabilityGridPageState();
}

class _LiabilityGridPageState extends State<LiabilityGridPage> {
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

    if (widget.openAddOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openAddLiabilitySheet(context, controller);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LiabilityGridView(controller: controller);
  }
}

class _LiabilityGridView extends CcGetView<LiabilityListController> {
  const _LiabilityGridView({required this.controller});

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
        const CcSpaceSM(),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      final balances = controller.borrowBalances;
      final isEdit = controller.isEditMode.value;

      if (balances.isEmpty) {
        return CcText(
          el.tr(CcLocaleKeys.liability_empty_state_v2),
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
        // Landscape tablet: three columns, capped at the two-column width.
        child: _capWide(
          context,
          GridView.builder(
            padding: EdgeInsets.all(
              context.respPadding(CcPaddingParams.PAGE_XS),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: CcTwoColumn.shouldUse(context) ? 3 : 2,
              mainAxisExtent: context.respDim(180),
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
        ),
      );
    });
  }

  Widget _capWide(BuildContext context, Widget child) =>
      CcTwoColumn.shouldUse(context)
      ? CcMaxWidth(maxWidth: CcTwoColumn.defaultMaxWidth, child: child)
      : child;

  Future<void> _openAddLiability(BuildContext context) =>
      _openAddLiabilitySheet(context, controller);

  void _confirmDelete(BuildContext context, String id) {
    showAdaptiveBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LiabilityDeleteConfirmSheet(
        liability: controller.liabilities
            .firstWhere((b) => b.liability.id == id)
            .liability,
        onDelete: () => controller.deleteLiability(context, id),
      ),
    );
  }
}

Future<void> _openAddLiabilitySheet(
  BuildContext context,
  LiabilityListController controller,
) async {
  final created = await AddLiabilitySheet.show(
    context,
    initialDirection: LiabilityDirection.borrow,
    showDirectionToggle: false,
  );
  if (created == true) {
    controller.load();
  }
}
