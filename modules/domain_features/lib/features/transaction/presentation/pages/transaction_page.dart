import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/transaction_controller.dart';
import '../widgets/transaction_page_header.dart';
import '../widgets/transaction_tab_bar.dart';
import '../widgets/transaction_tab_bar_view.dart';

@RoutePage()
class TransactionPage extends CcGetView<TransactionController> {
  const TransactionPage({super.key});

  @override
  bool get enableAppBar => false;

  @override
  bool get enableBottomNavigationBar => false;

  @override
  Widget? buildContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.24,
      tablet: 0.32,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    final visibleTabCount = controller.visibleTabs.length;

    return DefaultTabController(
      length: visibleTabCount,
      initialIndex: controller.selectedTabIndex.value.clamp(
        0,
        visibleTabCount - 1,
      ),
      child: FadePageWrapper(
        child: Stack(
          children: [
            Obx(() {
              final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;
              final hidden = keyboardUp || controller.isKeypadOpen.value;
              return AnimatedOpacity(
                opacity: hidden ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: hidden ? 0 : headerHeight,
                  child: TransactionPageHeader(
                    controller: controller,
                    onOpenReport: () => controller.openReport(context),
                    onSubmit: () => controller.submitCurrentForm(context),
                    expenseFormController: Get.find<ExpenseFormController>(),
                  ),
                ),
              );
            }),
            _buildTransactionContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.24,
      tablet: 0.32,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    final tabBarHeight = context.respDim(48);
    final overlap = tabBarHeight / 2;

    return Obx(() {
      final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;
      final hidden = keyboardUp || controller.isKeypadOpen.value;

      return Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: hidden ? 0 : headerHeight - overlap,
          ),
          TransactionTabBar(controller: controller),
          const CcSpaceSM(),
          Expanded(child: TransactionTabBarView(controller: controller)),
        ],
      );
    });
  }
}
