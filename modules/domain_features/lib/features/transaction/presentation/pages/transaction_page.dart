import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/money_format.dart';
import '../get_x/transaction_controller.dart';
import '../widgets/expense_form.dart';
import '../widgets/receipt_form.dart';
import '../widgets/transfer_form.dart';
import 'transaction_history_page.dart';

@RoutePage()
class TransactionPage extends CcGetView<TransactionController> {
  const TransactionPage({super.key});

  @override
  bool get enableAppBar => false;

  @override
  bool get enableBottomNavigationBar => false;

  @override
  Widget? buildContent() {
    return Builder(
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: FadePageWrapper(
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
                        ExpenseForm(onSaved: controller.refreshData),
                        ReceiptForm(onSaved: controller.refreshData),
                        TransferForm(onSaved: controller.refreshData),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TransactionHistoryPage(initialTab: controller.selectedTabIndex.value),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      color: context.ccColorScheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            context.respPadding(CcPaddingParams.SPACE_MD),
        left: context.respPadding(CcPaddingParams.SPACE_LG),
        right: context.respPadding(CcPaddingParams.SPACE_LG),
        bottom: context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CcText(
                  el.tr(CcLocaleKeys.transaction_title),
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    color: context.ccColorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: context.respFontSize(16),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _openHistory(context),
                borderRadius: BorderRadius.circular(context.respDim(20)),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: context.respIconSize(baseSize: 18),
                        color: context.ccColorScheme.onPrimary,
                      ),
                      const CcSpaceXS(),
                      CcText(
                        el.tr(CcLocaleKeys.transaction_history),
                        textStyle: context.ccTextTheme.labelMedium?.copyWith(
                          color: context.ccColorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: context.respFontSize(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const CcSpaceSM(),
          Obx(
            () => Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: context.respIconSize(baseSize: 14),
                  color: context.ccColorScheme.onPrimary.withOpacity(0.8),
                ),
                const CcSpaceXS(),
                CcText(
                  '${el.tr(CcLocaleKeys.transaction_wallet)}  ${formatVndShort(controller.walletTotal.value)}',
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    color: context.ccColorScheme.onPrimary.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: context.respFontSize(13),
                  ),
                ),
              ],
            ),
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
            align: Alignment.center,
            textAlign: TextAlign.center,
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
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      height: context.respDim(48),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.respDim(25)),
      ),
      child: Obx(() {
        return TabBar(
          onTap: controller.setTabIndex,
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
          labelColor: switch (controller.selectedTabIndex.value) {
            0 => context.ccColorScheme.error,
            2 => const Color(0xFF2F80ED),
            _ => context.ccColorScheme.primary,
          },
          unselectedLabelColor: context.ccColorScheme.onSurfaceVariant,
          labelStyle: context.ccTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.respFontSize(12),
          ),
          labelPadding: EdgeInsets.zero,
          tabs: [
            Tab(text: el.tr(CcLocaleKeys.transaction_expense_slip)),
            Tab(text: el.tr(CcLocaleKeys.transaction_income_slip)),
            const Tab(text: 'Chuyển khoản'),
          ],
        );
      }),
    );
  }
}
