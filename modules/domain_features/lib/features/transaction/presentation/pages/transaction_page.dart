import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/income_form_controller.dart';
import '../get_x/transaction_controller.dart';
import '../get_x/transfer_form_controller.dart';
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
    return DefaultTabController(
      length: 3,
      child: FadePageWrapper(
        child: Stack(
          children: [
            TransactionPageHeader(
              controller: controller,
              onOpenReport: () => _openReport(context),
              onSubmit: () => _submitCurrentForm(context),
            ),
            _buildTransactionContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionContent(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = context.respDim(180) + topPadding;
    final tabBarHeight = context.respDim(60);
    final overlap = tabBarHeight / 2;

    return Column(
      children: [
        SizedBox(height: headerHeight - overlap),
        TransactionTabBar(controller: controller),
        const CcSpaceSM(),
        TransactionTabBarView(controller: controller),
      ],
    );
  }

  void _openReport(BuildContext context) {
    if (Get.isRegistered<ReportController>()) {
      Get.find<ReportController>().load(showLoading: false);
    }
    context.router.push(const ReportRoute());
  }

  void _submitCurrentForm(BuildContext context) {
    controller.flashWalletSummary();
    switch (controller.selectedTabIndex.value) {
      case 0:
        if (Get.isRegistered<ExpenseFormController>()) {
          Get.find<ExpenseFormController>().submitForm(context);
        }
        break;
      case 1:
        if (Get.isRegistered<IncomeFormController>()) {
          Get.find<IncomeFormController>().submitForm(context);
        }
        break;
      case 2:
        if (Get.isRegistered<TransferFormController>()) {
          Get.find<TransferFormController>().submitForm(context);
        }
        break;
    }
  }
}
