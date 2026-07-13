import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/navigation/domain_router.gr.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../get_x/transaction_controller.dart';
import '../widgets/shimmer_transaction_card.dart';
import '../widgets/transaction_card.dart';

/// Read-only history of recorded transactions ("Lịch sử thu/chi"), split into
/// Chi (expense) / Thu (income) tabs. Pushed from the entry screen.
class TransactionHistoryPage extends StatefulWidget {
  final int initialTab;

  const TransactionHistoryPage({super.key, this.initialTab = 0});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with CcPullRefreshMixin {
  final TransactionController _controller = Get.find<TransactionController>();

  @override
  void initState() {
    super.initState();
    _controller.refreshData();
  }

  void _openReport() {
    // The report controller is kept alive by GetX, so its `onReady` only fires
    // on the first open. Refresh it here so re-opening reflects transactions
    // added in between; the first-ever open lets `onReady` do the initial load.
    if (Get.isRegistered<ReportController>()) {
      Get.find<ReportController>().load(showLoading: false);
    }
    context.router.push(const ReportRoute());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab.clamp(0, 1),
      child: Scaffold(
        backgroundColor: context.ccColorScheme.surface,
        appBar: buildDomainGradientAppBar(
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
              el.tr(CcLocaleKeys.transaction_history),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: context.ccColorScheme.onPrimary,
                fontWeight: CcTypographyParams.bold,
              ),
            ),
          ),
          actions: [
            CcIconButton.bouncing(
              icon: Icon(
                Icons.bar_chart_rounded,
                size: context.respIconSize(baseSize: 24),
                color: context.ccColorScheme.onPrimary,
              ),
              tooltip: el.tr(CcLocaleKeys.report_title),
              onTap: _openReport,
            ),
          ],
          bottom: TabBar(
            indicatorColor: context.ccColorScheme.onPrimary,
            labelColor: context.ccColorScheme.onPrimary,
            unselectedLabelColor: context.ccColorScheme.onPrimary.withOpacity(
              0.6,
            ),
            labelStyle: context.ccTextTheme.titleSmall?.copyWith(
              fontWeight: CcTypographyParams.bold,
              fontSize: context.respFontSize(12),
            ),
            tabs: [
              Tab(text: el.tr(CcLocaleKeys.transaction_expense_slip)),
              Tab(text: el.tr(CcLocaleKeys.transaction_income_slip)),
            ],
          ),
        ),
        body: Obx(() {
          final isLoading = _controller.isLoading.value;
          return TabBarView(
            children: [
              _buildList(context, isLoading, 'expense'),
              _buildList(context, isLoading, 'income'),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildList(BuildContext context, bool isLoading, String type) {
    final items = _controller.transactions
        .where((t) => t.type == type)
        .toList();

    if (!isLoading && items.isEmpty) {
      return const EmptyPage();
    }

    return buildPullToRefresh(
      context: context,
      onRefresh: _controller.refreshData,
      child: ListView.builder(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_SM)),
        itemCount: isLoading ? 5 : items.length,
        itemBuilder: (context, index) {
          if (isLoading) {
            return const ShimmerTransactionCard();
          }
          return TransactionCard(transaction: items[index]);
        },
      ),
    );
  }
}
