import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/budget/budget_name_helper.dart';
import '../../../../core/get_x/prj_get_view.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../get_x/budget_limit_controller.dart';
import '../widgets/add_budget_limit_sheet.dart';
import '../widgets/budget_limit_grid.dart';

@RoutePage()
class BudgetLimitListPage extends StatefulWidget {
  const BudgetLimitListPage({super.key});

  @override
  State<BudgetLimitListPage> createState() => _BudgetLimitListPageState();
}

class _BudgetLimitListPageState extends State<BudgetLimitListPage> {
  late final BudgetLimitController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BudgetLimitController>();
    // Ensure edit mode is always off when entering the page.
    controller.hasEditMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return _BudgetLimitListView(controller: controller);
  }
}

class _BudgetLimitListView extends PrjGetView<BudgetLimitController> {
  const _BudgetLimitListView({required this.controller});

  @override
  final BudgetLimitController controller;

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return CcGradientAppBar.create(
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
          el.tr(PrjLocaleKeys.budget_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          onTap: () => _openAddBudgetLimitSheet(context),
          tooltip: el.tr(PrjLocaleKeys.budget_add_title),
          icon: Icon(
            Icons.add_rounded,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
        ),
        Obx(
          () => CcIconButton.bouncing(
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
        ),
      ],
    );
  }

  @override
  Widget? get floatingActionButton => null;

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(() {
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.respPadding(CcPaddingParams.SPACE_LG),
                  context.respPadding(CcPaddingParams.SPACE_MD),
                  context.respPadding(CcPaddingParams.SPACE_LG),
                  context.respPadding(CcPaddingParams.SPACE_XS),
                ),
                child: _buildSeeMoreDescription(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                  context.respPadding(CcPaddingParams.SPACE_MD),
                ),
                child: BudgetLimitGrid(
                  key: const ValueKey('budget-limit-grid'),
                  controller: controller,
                  onOpenForm: _openAddBudgetLimitSheet,
                  onDelete: _confirmDeleteBudgetLimit,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _openAddBudgetLimitSheet(
    BuildContext context, {
    BudgetLimitEntity? editTarget,
  }) {
    CcAdaptiveBottomSheet.show<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: context.brXl),
      builder: (_) => AddBudgetLimitSheet(editTarget: editTarget),
    );
  }

  Future<void> _confirmDeleteBudgetLimit(
    BuildContext context,
    BudgetLimitEntity budget,
  ) async {
    final name = BudgetNameHelper.getDisplayName(
      name: budget.name,
      categoryNameKey: null,
    );
    final confirmed = await CcConfirmSheet.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: el.tr(PrjLocaleKeys.budget_delete_title),
      message: el.tr(
        PrjLocaleKeys.budget_delete_confirm,
        namedArgs: {'name': name},
      ),
      confirmLabel: el.tr(PrjLocaleKeys.common_delete),
    );
    if (confirmed) await controller.deleteBudget(budget.id);
  }

  Widget _buildSeeMoreDescription(BuildContext context) {
    final text = el.tr(PrjLocaleKeys.budget_description);
    return CcBouncing(
      onTap: () => CcDialogHelper.showMessageBottomSheet(
        context: context,
        title: el.tr(PrjLocaleKeys.budget_title),
        hasOnlyConfirm: true,
        customWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDescriptionItem(
              context,
              icon: Icons.pie_chart_outline_rounded,
              text: el.tr(PrjLocaleKeys.budget_description),
            ),
            const CcSpaceMD(),
            _buildDescriptionItem(
              context,
              icon: Icons.bolt_rounded,
              text: el.tr(PrjLocaleKeys.budget_fixed_price_description),
            ),
            const CcSpaceMD(),
            _buildDescriptionItem(
              context,
              icon: Icons.drag_indicator_rounded,
              text: el.tr(PrjLocaleKeys.budget_drag_reorder_hint),
            ),
          ],
        ),
      ),
      borderRadius: context.brSm,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: context.ccColorScheme.onSurface.withOpacity(0.05),
          borderRadius: context.brSm,
        ),
        child: Row(
          children: [
            Expanded(
              child: CcText(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                    0.5,
                  ),
                  fontSize: context.respFontSize(9),
                ),
              ),
            ),
            const CcSpaceXS(),
            CcText(
              '... See more',
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: context.ccColorScheme.primary,
                fontSize: context.respFontSize(9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final scheme = context.ccColorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(context.respDim(6)),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: context.respIconSize(baseSize: 18),
            color: scheme.primary,
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: CcText(
            text,
            maxLines: 10,
            textAlign: TextAlign.start,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
