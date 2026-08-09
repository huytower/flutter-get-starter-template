import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
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
    final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;

    // Responsive height factor based on screen height to prevent content overlap
    // on small phones while maintaining aesthetic proportions on tablets.
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.22, // Increased for mobile to accommodate all header info
      tablet: 0.2, // Tablets
    );
    final headerHeight = screenHeight * headerHeightFactor;

    // Read once at construction time: this TabController is fresh on every
    // mount (the page is popped on tab-bar navigation), so a level unlocked
    // elsewhere is always reflected by the time the user revisits this page.
    final visibleTabCount = controller.visibleTabs.length;

    return DefaultTabController(
      length: visibleTabCount,
      // Reads the GetX tab index at construction time so a tab selected
      // programmatically before this page mounts (e.g. LoanListController
      // jumping into the Loan tab's Settle sub-mode) actually lands on that
      // tab — this TabController is fresh on every mount (the page is popped
      // on tab-bar navigation), so without this it would always reset to 0
      // regardless of TransactionController.selectedTabIndex.
      initialIndex: controller.selectedTabIndex.value.clamp(
        0,
        visibleTabCount - 1,
      ),
      child: FadePageWrapper(
        child: Stack(
          children: [
            Obx(() {
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
      mobile: 0.25,
      tablet: 0.28,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    final tabBarHeight = context.respDim(140);
    final overlap = tabBarHeight / 2;

    final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;

    return Obx(() {
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
