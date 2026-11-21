import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_view.dart';
import '../../../budget_limit/presentation/get_x/budget_limit_controller.dart';
import '../../../liability/presentation/get_x/borrow_form_controller.dart';
import '../../../liability/presentation/get_x/lend_form_controller.dart';
import '../get_x/expense_form_controller.dart' hide ever;
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
  bool get useSafeArea => false;

  @override
  bool get enableBottomNavigationBar => false;

  /// Opts out of the standard page background: the immersive header and the
  /// per-form tinted surfaces are this page's own backdrop.
  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) => body;

  @override
  Widget? buildContent(BuildContext context) {
    if (!Get.isRegistered<BudgetLimitController>()) {
      Get.put(getIt<BudgetLimitController>());
    }
    if (!Get.isRegistered<InvestmentFormController>()) {
      Get.put(getIt<InvestmentFormController>());
    }
    if (!Get.isRegistered<BorrowFormController>()) {
      Get.put(getIt<BorrowFormController>());
    }
    if (!Get.isRegistered<LendFormController>()) {
      Get.lazyPut(() => getIt<LendFormController>());
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
  late final Worker _tabWorker;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: controller.visibleTabs.length,
      vsync: this,
      initialIndex: controller.selectedTabIndex.value,
    );

    _tabController.addListener(_handleTabChange);

    // Sync controller state back to the UI TabController (e.g. for AI-detected
    // intent switching).
    _tabWorker = ever(controller.selectedTabIndex, (int index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });
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
    _tabWorker.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  /// Measured height of the one-row header content, once laid out.
  double? _inlineRowHeight;

  void _onInlineRowMeasured(double height) {
    final previous = _inlineRowHeight;
    if (!mounted || (previous != null && (height - previous).abs() < 0.5)) {
      return;
    }
    setState(() => _inlineRowHeight = height);
  }

  /// Hero header height. Phones and portrait tablets keep the screen-height
  /// [factor]. On wide-but-short windows the header is a single row, so it is
  /// sized to that row (measured; estimated on the first frame): the tab bar
  /// never covers the banner and no empty band is left above it.
  double _headerHeight(BuildContext context, double factor) {
    if (!TransactionPageHeader.useInlineLayout(context)) {
      return context.respHeaderHeight(factor);
    }
    final row = _inlineRowHeight ?? context.respDim(56);
    final gap = context.respPadding(CcPaddingParams.SPACE_MD);
    return MediaQuery.paddingOf(context).top +
        gap +
        row +
        gap +
        _tabBarOverlap(context);
  }

  /// The tab bar straddles the header's bottom edge by half its height.
  double _tabBarOverlap(BuildContext context) => context.respDim(64) / 2;

  @override
  Widget build(BuildContext context) {
    final headerHeightFactor = context.windowSizeClass.select(
      compact: 0.27,
      medium: 0.28,
    );
    final headerHeight = _headerHeight(context, headerHeightFactor);

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
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: headerHeight,
                      maxHeight: headerHeight,
                      child: TransactionPageHeader(
                        controller: controller,
                        onOpenReport: () => controller.openReport(context),
                        onSubmit: () => controller.submitCurrentForm(context),
                        expenseFormController:
                            Get.find<ExpenseFormController>(),
                        onInlineRowHeightChanged: _onInlineRowMeasured,
                      ),
                    ),
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
    final headerHeightFactor = context.windowSizeClass.select(
      compact: 0.27,
      medium: 0.29,
    );
    final headerHeight = _headerHeight(context, headerHeightFactor);
    final overlap = _tabBarOverlap(context);

    return Obx(() {
      final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;
      final hidden = keyboardUp || controller.isKeypadOpen.value;
      final showInvestmentBadge = controller.showInvestmentBadge;

      // Wide windows (beside the rail, large tablets): the tab bar and form
      // cards stop at the content width, while the category / asset
      // carousels start aligned with them and scroll out to the screen edge
      // (CcContentInset). Phones and portrait tablets: inset 0, unchanged.
      return CcContentInset(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: hidden ? 0 : headerHeight - overlap,
            ),
            CcContentPadding(
              child: TransactionTabBar(
                controller: controller,
                tabController: _tabController,
                showInvestmentBadge: showInvestmentBadge,
                showLiabilityBadge: controller.showLiabilityBadge,
                showLendBadge: controller.showLendBadge,
              ),
            ),
            Expanded(
              child: TransactionTabBarView(
                controller: controller,
                tabController: _tabController,
              ),
            ),
          ],
        ),
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

  @override
  bool updateShouldNotify(_TabControllerProvider oldWidget) =>
      controller != oldWidget.controller;
}
