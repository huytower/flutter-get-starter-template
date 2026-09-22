import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../get_x/budget_limit_controller.dart';
import '../widgets/add_budget_limit_sheet.dart';
import '../widgets/budget_limit_delete_confirm_sheet.dart';
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
    controller.isEditMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return _BudgetLimitListView(controller: controller);
  }
}

class _BudgetLimitListView extends CcGetView<BudgetLimitController> {
  const _BudgetLimitListView({required this.controller});

  @override
  final BudgetLimitController controller;

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
          el.tr(CcLocaleKeys.budget_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          onTap: () => _openAddBudgetLimitSheet(context),
          tooltip: el.tr(CcLocaleKeys.budget_add_title),
          icon: Icon(
            Icons.add_rounded,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
        ),
        Obx(
          () => CcIconButton.bouncing(
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
        ),
      ],
    );
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) =>
      ColoredBox(color: context.ccColorScheme.background, child: body);

  @override
  Widget? get floatingActionButton => null;

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(() {
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: context.brXl),
      builder: (_) => AddBudgetLimitSheet(editTarget: editTarget),
    );
  }

  void _confirmDeleteBudgetLimit(
    BuildContext context,
    BudgetLimitEntity budget,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: context.brXl),
      builder: (_) => BudgetLimitDeleteConfirmSheet(
        budget: budget,
        onDelete: () => controller.deleteBudget(budget.id),
      ),
    );
  }

  Widget _buildSeeMoreDescription(BuildContext context) {
    final text = el.tr(CcLocaleKeys.budget_description);
    return CcBouncing(
      onTap: () => CcDialogHelper.showMessageBottomSheet(
        context: context,
        title: el.tr(CcLocaleKeys.budget_title),
        isOnlyConfirm: true,
        customWidget: Column(
          children: [
            CcText(
              el.tr(CcLocaleKeys.budget_description),
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(CcLocaleKeys.budget_fixed_price_description),
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(CcLocaleKeys.budget_drag_reorder_hint),
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
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
}
