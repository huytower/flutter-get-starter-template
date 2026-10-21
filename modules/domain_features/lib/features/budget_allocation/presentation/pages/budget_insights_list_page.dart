import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_view.dart';
import '../get_x/budget_allocation_controller.dart';
import '../widgets/budget_insights_section.dart';

@RoutePage()
class BudgetInsightsListPage extends StatefulWidget {
  const BudgetInsightsListPage({super.key});

  @override
  State<BudgetInsightsListPage> createState() => _BudgetInsightsListPageState();
}

class _BudgetInsightsListPageState extends State<BudgetInsightsListPage> {
  late final BudgetAllocationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BudgetAllocationController>()
        ? Get.find<BudgetAllocationController>()
        : Get.put(getIt<BudgetAllocationController>());
  }

  @override
  Widget build(BuildContext context) {
    return _BudgetInsightsListView(controller: controller);
  }
}

class _BudgetInsightsListView extends CcGetView<BudgetAllocationController> {
  const _BudgetInsightsListView({required this.controller});

  @override
  final BudgetAllocationController controller;

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      leading: CcIconButton.bouncing(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
        onTap: () => Navigator.of(context).pop(),
      ),
      title: Center(
        child: CcText(
          el.tr(CcLocaleKeys.budget_insights_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) =>
      ColoredBox(color: context.ccColorScheme.background, child: body);

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(() {
      final insights = controller.insights.value;
      if (insights == null || !insights.hasAnything) {
        return CcSectionEmptyState(
          message: el.tr(CcLocaleKeys.budget_empty),
          verticalPadding: 24,
          horizontalPadding: CcPaddingParams.SPACE_LG,
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: context.respPadding(CcPaddingParams.SPACE_MD),
        ),
        child: BudgetInsightsSection(controller: controller, showAll: true),
      );
    });
  }
}
