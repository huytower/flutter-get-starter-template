import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../core/di/di.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_limit/domain/usecases/sort_budget_limits_by_limit_usecase.dart';
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
                  color: scheme.onBackground,
                  fontSize: context.respFontSize(CcTypographyParams.titleSmall),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAddBudget(context),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      size: context.respIconSize(baseSize: 20),
                      color: scheme.primary,
                    ),
                  ),
                  SizedBox(width: context.respDim(8)),
                  GestureDetector(
                    onTap: () =>
                        context.router.push(const BudgetLimitManagementRoute()),
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
          final budgets = getIt<SortBudgetLimitsByLimitUseCase>().call(
            Get.find<BudgetLimitController>().budgets,
            limit: 4,
          );
          if (budgets.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
                vertical: context.respDim(12),
              ),
              child: CcText(
                el.tr(CcLocaleKeys.budget_empty),
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
            ),
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
                  BudgetLimitGridCard(stats: budgets[i]),
            ),
          );
        }),
        SizedBox(height: context.respDim(24)),
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
