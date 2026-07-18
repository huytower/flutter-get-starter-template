import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../core/di/di.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_limit/domain/usecases/sort_budget_limits_by_progress_usecase.dart';
import '../../../budget_limit/presentation/get_x/budget_limit_controller.dart';
import '../../../budget_limit/presentation/widgets/add_budget_limit_form_sheet.dart';
import '../../../budget_limit/presentation/widgets/budget_limit_grid_card.dart';

class BudgetPreviewSection extends StatelessWidget {
  const BudgetPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_MD),
            context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(CcLocaleKeys.budget_this_month),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAddBudget(context),
                    child: const CcIconToken(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                  ),
                  const CcSpaceSM(),
                  GestureDetector(
                    onTap: () => context.router.push(const BudgetLimitRoute()),
                    child: CcText(
                      el.tr(CcLocaleKeys.budget_see_all),
                      textStyle: context.ccTextTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: CcTypographyParams.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(() {
          final budgets = getIt<SortBudgetLimitsByProgressUseCase>().call(
            Get.find<BudgetLimitController>().budgets,
            limit: 4,
          );
          if (budgets.isEmpty) {
            return CcSymmetricPadding(
              horizontal: CcPaddingParams.SPACE_LG,
              vertical: 12,
              child: CcText(
                el.tr(CcLocaleKeys.budget_empty),
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return CcSymmetricPadding(
            horizontal: CcPaddingParams.SPACE_LG,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: context.respDim(110),
                crossAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
                mainAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
              ),
              itemCount: budgets.length,
              itemBuilder: (context, i) =>
                  BudgetLimitGridCard(stats: budgets[i], showDragHandle: false),
            ),
          );
        }),
        const CcSpaceXL(),
      ],
    );
  }

  void _openAddBudget(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddBudgetLimitFormSheet(),
    );
  }
}
