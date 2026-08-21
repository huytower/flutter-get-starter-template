import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_view.dart';
import '../../../liability/presentation/get_x/liability_form_controller.dart';
import '../../../liability/presentation/get_x/lend_form_controller.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/investment_form_controller.dart';
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
    if (!Get.isRegistered<InvestmentFormController>()) {
      Get.put(getIt<InvestmentFormController>());
    }
    if (!Get.isRegistered<LiabilityFormController>()) {
      Get.put(getIt<LiabilityFormController>());
    }
    if (!Get.isRegistered<LendFormController>()) {
      Get.put(getIt<LendFormController>());
    }

    return const _TransactionPageContent();
  }
}

class _TransactionPageContent extends StatefulWidget {
  const _TransactionPageContent();

  @override
  State<_TransactionPageContent> createState() =>
      _TransactionPageContentState();
}

class _TransactionPageContentState extends State<_TransactionPageContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TransactionController controller = Get.find<TransactionController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: controller.visibleTabs.length,
      vsync: this,
      initialIndex: controller.selectedTabIndex.value,
    );

    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      controller.selectedTabIndex.value = _tabController.index;
      controller.isSecondaryCardFront.value = _tabController.index >= 2;
      controller.markStackInteracted();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.24,
      tablet: 0.32,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    // Use a custom inherited widget or provide the controller to TransactionTabBar
    // but here we can just wrap our content with a TabController provider.
    return _TabControllerProvider(
      controller: _tabController,
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

    final tabBarHeight = context.respDim(64);
    final overlap = tabBarHeight / 2;

    return Obx(() {
      final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;
      final hidden = keyboardUp || controller.isKeypadOpen.value;
      final showInvestmentBadge = controller.showInvestmentBadge;

      return Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: hidden ? 0 : headerHeight - overlap,
          ),
          TransactionTabBar(
            controller: controller,
            tabController: _tabController,
            showInvestmentBadge: showInvestmentBadge,
            showLiabilityBadge: controller.showLiabilityBadge,
          ),
          Expanded(
            child: TransactionTabBarView(
              controller: controller,
              tabController: _tabController,
            ),
          ),
        ],
      );
    });
  }
}

/// Simple inherited widget to provide the TabController if children need it via context
class _TabControllerProvider extends InheritedWidget {
  const _TabControllerProvider({
    required this.controller,
    required super.child,
  });

  final TabController controller;

  static TabController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TabControllerProvider>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(_TabControllerProvider oldWidget) =>
      controller != oldWidget.controller;
}
