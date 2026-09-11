import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_limit/domain/usecases/sort_budget_limits_by_progress_usecase.dart';
import '../../../budget_limit/export_budget_limit.dart';
import '../../../guideline/export_guideline.dart';

class BudgetLimitPreviewSection extends StatelessWidget {
  const BudgetLimitPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final guideline = Get.find<GuidelineController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcPadding(
          CcSectionHeader(
            title: el.tr(CcLocaleKeys.budget_this_month),
            icon: Icons.bar_chart,
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CcBouncing(
                    onTap: () => _openAddBudget(context),
                    child: const CcIconToken(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                  ),
                  Obx(() {
                    if (!guideline.isTaskActive('budget_limit') &&
                        !guideline.isTaskActive('min_living')) {
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      bottom: context.respDim(10),
                      right: context.respDim(10),
                      child: PrjGuidelineBadge(
                        size: context.respDim(6),
                        label: guideline.bannerDescription,
                        labelAbove: true,
                        growRight: false,
                      ),
                    );
                  }),
                ],
              ),
              Obx(() {
                final hasBudgets =
                    Get.find<BudgetLimitController>().budgets.isNotEmpty;
                if (!hasBudgets) return const SizedBox.shrink();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CcSpaceSM(),
                    CcTextButton(
                      text: el.tr(CcLocaleKeys.budget_see_all),
                      onTap: () =>
                          context.router.push(const BudgetLimitListRoute()),
                    ),
                  ],
                );
              }),
            ],
          ),
          0, // bottom
          CcPaddingParams.SPACE_LG, // left
          CcPaddingParams.SPACE_MD, // right
          0, // top
        ),
        const CcSpaceSM(),
        Obx(() {
          final budgets = getIt<SortBudgetLimitsByProgressUseCase>().call(
            Get.find<BudgetLimitController>().budgets,
            limit: 4,
          );
          if (budgets.isEmpty) {
            return CcSectionEmptyState(
              message: el.tr(CcLocaleKeys.budget_empty),
              verticalPadding: 12,
              horizontalPadding: CcPaddingParams.SPACE_LG,
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
              itemBuilder: (context, i) => CcBouncing(
                onTap: () => context.router.push(const BudgetLimitListRoute()),
                borderRadius: BorderRadius.circular(12),
                child: BudgetLimitGridCard(
                  stats: budgets[i],
                  showDragHandle: false,
                ),
              ),
            ),
          );
        }),
        const CcSpaceMD(),
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
      builder: (_) => const AddBudgetLimitSheet(),
    );
  }
}
