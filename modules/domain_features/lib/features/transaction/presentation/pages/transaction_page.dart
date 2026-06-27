import 'package:auto_route/annotations.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/entities/transaction_entity.dart';
import '../get_x/transaction_controller.dart';
import '../ui/widgets/shimmer_transaction_card.dart';
import '../ui/widgets/transaction_card.dart';

@RoutePage()
class TransactionPage extends CcGetView<TransactionController>
    with CcPullRefreshMixin {
  const TransactionPage({super.key});

  @override
  bool get enableAppBar => false;

  @override
  bool get enableBottomNavigationBar => false;

  @override
  Widget? buildContent() {
    return Builder(
      builder: (context) {
        final transactions = controller.transactions;
        final isLoading =
            controller.layoutStatus.value == CcLayoutStatus.loading ||
            controller.layoutStatus.value == CcLayoutStatus.loadMore;

        return FadePageWrapper(
          child: Builder(
            builder: (context) => buildPullToRefresh(
              context: context,
              onRefresh: controller.refreshData,
              child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  backgroundColor: context.ccColorScheme.surface,
                  body: Column(
                    children: [
                      _buildTopNav(context),
                      const CcSpaceMD(),
                      _buildTabBar(context),
                      const CcSpaceSM(),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTransactionList(context, isLoading, transactions, 'expense'),
                            _buildTransactionList(context, isLoading, transactions, 'income'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    bool isLoading,
    RxList<TransactionEntity> transactions,
    String type,
  ) {
    final filteredTransactions = transactions.where((t) => t.type == type).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: isLoading ? 5 : filteredTransactions.length,
      itemBuilder: (context, index) {
        if (isLoading) {
          return const ShimmerTransactionCard();
        }
        return TransactionCard(transaction: filteredTransactions[index]);
      },
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      color: context.ccColorScheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + context.respPadding(CcPaddingParams.SPACE_MD),
        left: context.respPadding(CcPaddingParams.SPACE_LG),
        right: context.respPadding(CcPaddingParams.SPACE_LG),
        bottom: context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      child: Column(
        children: [
          CcText(
            el.tr(CcLocaleKeys.transaction_title),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: context.respFontSize(16),
            ),
          ),
          const CcSpaceLG(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWalletChip(
                context,
                Icons.account_balance_wallet,
                el.tr(CcLocaleKeys.transaction_wallet),
                '0',
                Colors.yellow,
              ),
              _buildWalletChip(
                context,
                Icons.security,
                el.tr(CcLocaleKeys.transaction_emergency),
                '0',
                Colors.orangeAccent,
              ),
              _buildWalletChip(
                context,
                Icons.rocket_launch,
                el.tr(CcLocaleKeys.transaction_investment),
                '0',
                Colors.lightBlueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletChip(
    BuildContext context,
    IconData icon,
    String label,
    String amount,
    Color iconColor,
  ) {
    return Container(
      width: context.respDim(105),
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(context.respDim(12)),
        border: Border.all(color: context.ccColorScheme.onPrimary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: context.respIconSize(baseSize: 14),
                color: iconColor,
              ),
              const CcSpaceXS(),
              CcText(
                label,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  fontSize: context.respFontSize(9),
                  fontWeight: FontWeight.bold,
                  color: context.ccColorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const CcSpaceXS(),
          CcText(
            amount,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.ccColorScheme.onPrimary,
              fontSize: context.respFontSize(15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.respPadding(CcPaddingParams.PAGE_MD)),
      height: context.respDim(48),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.respDim(25)),
      ),
      child: Obx(() {
        return TabBar(
          onTap: (index) {
            controller.setTabIndex(index);
          },
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: context.ccColorScheme.surface,
            borderRadius: BorderRadius.circular(context.respDim(25)),
            boxShadow: [
              BoxShadow(
                color: context.ccColorScheme.onSurface.withOpacity(0.05),
                blurRadius: context.respDim(4),
                offset: Offset(0, context.respDim(2)),
              ),
            ],
          ),
          labelColor: controller.selectedTabIndex.value == 0
              ? context.ccColorScheme.error
              : context.ccColorScheme.primary,
          unselectedLabelColor: context.ccColorScheme.onSurfaceVariant,
          labelStyle: context.ccTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.respFontSize(14),
          ),
          tabs: [
            Tab(text: el.tr(CcLocaleKeys.transaction_expense_slip)),
            Tab(text: el.tr(CcLocaleKeys.transaction_income_slip)),
          ],
        );
      }),
    );
  }
}
