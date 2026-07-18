import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../get_x/budget_limit_controller.dart';
import '../widgets/add_budget_limit_form_sheet.dart';
import '../widgets/budget_limit_grid.dart';

@RoutePage()
class BudgetLimitPage extends CcGetView<BudgetLimitController> {
  const BudgetLimitPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      leading: CcIconButton.bouncing(
        icon: Icon(
          controller.isEditMode.value
              ? Icons.close_rounded
              : Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
        onTap: () {
          controller.isEditMode.value = false;
          Navigator.of(context).pop();
        },
      ),
      title: Center(
        child: CcText(
          el.tr(CcLocaleKeys.budget_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold
          ),
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          onTap: () => _openAddBudgetLimitForm(context),
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
    // Obx here so isEditMode.value is tracked directly in the reactive context —
    // reading it inside a Builder callback (deferred build) would escape tracking.
    return Obx(() {
      final isEdit = controller.isEditMode.value;
      return Builder(
        builder: (context) => CustomScrollView(
          slivers: [
            // Always present so BudgetLimitGrid stays at sliver-index 1 and its
            // StatefulWidget state survives mode switches.
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.respPadding(16),
                  context.respPadding(12),
                  context.respPadding(16),
                  context.respPadding(6),
                ),
                child: Column(
                  children: [
                    CcText(
                      el.tr(CcLocaleKeys.budget_description),
                      maxLines: 3,
                      textStyle: context.ccTextTheme.labelSmall?.copyWith(
                        color: context.ccColorScheme.onSurfaceVariant
                            .withOpacity(0.5)
                      ),
                    ),
                    const CcSpaceXS(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: context.respIconSize(baseSize: 14),
                          color: context.ccColorScheme.primary.withOpacity(0.5),
                        ),
                        const CcSpaceXS(),
                        Expanded(
                          child: CcText(
                            el.tr(CcLocaleKeys.budget_fixed_price_description),
                            maxLines: 3,
                            textStyle: context.ccTextTheme.labelSmall?.copyWith(
                              color: context.ccColorScheme.onSurfaceVariant
                                  .withOpacity(0.5)
                            ),
                          ),
                        ),
                      ],
                    ),
                    const CcSpaceXS(),
                    isEdit
                        ? const CcSpaceMD()
                        : Row(
                            children: [
                              Icon(
                                Icons.swap_vert,
                                size: context.respIconSize(baseSize: 14),
                                color: context.ccColorScheme.onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const CcSpaceXS(),
                              CcText(
                                el.tr(CcLocaleKeys.budget_drag_reorder_hint),
                                textStyle: context.ccTextTheme.labelSmall
                                    ?.copyWith(
                                      color: context
                                          .ccColorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.5)
                                    ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: BudgetLimitGrid(
                  key: const ValueKey('budget-limit-grid'),
                  controller: controller,
                  onOpenForm: _openAddBudgetLimitForm,
                  onDelete: _confirmDeleteBudgetLimit,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _openAddBudgetLimitForm(
    BuildContext context, {
    BudgetLimitEntity? editTarget,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddBudgetLimitFormSheet(editTarget: editTarget),
    );
  }

  void _confirmDeleteBudgetLimit(
    BuildContext context,
    BudgetLimitEntity budget,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(el.tr(CcLocaleKeys.budget_delete_title)),
        content: Text(
          el.tr(
            CcLocaleKeys.budget_delete_confirm,
            namedArgs: {'name': budget.name},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(el.tr(CcLocaleKeys.common_cancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              controller.deleteBudget(budget.id);
            },
            child: Text(el.tr(CcLocaleKeys.common_delete)),
          ),
        ],
      ),
    );
  }
}
