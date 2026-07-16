import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/income_form_controller.dart';
import '../get_x/transaction_controller.dart';
import '../get_x/transfer_form_controller.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_form.dart';
import '../widgets/transaction_wallet_summary.dart';
import '../widgets/transfer_form.dart';

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
            _buildHeroHeader(context),
            _buildTransactionContent(context),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HERO HEADER SECTION
  // ===========================================================================

  Widget _buildHeroHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = context.respDim(200) + topPadding;

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.respDim(16)),
          bottomRight: Radius.circular(context.respDim(16)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _buildHeroBackground(),
          _buildHeroForeground(context, topPadding),
        ],
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Positioned.fill(
      child: Image.asset('assets/bg/bg_header.webp', fit: BoxFit.cover),
    );
  }

  Widget _buildHeroForeground(BuildContext context, double topPadding) {
    return Positioned(
      top: -150,
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeaderTitleSection(context),
            _buildHeaderActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTitleSection(BuildContext context) {
    return Expanded(
      child: Obx(() {
        // Explicitly access observable to register dependency for this Obx
        final bool showSummary = controller.showWalletSummaryTemporarily.value;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[...previousChildren, ?currentChild],
            );
          },
          child: showSummary
              ? const TransactionWalletSummary(key: ValueKey('wallet_summary'))
              : _buildPageTitle(context),
        );
      }),
    );
  }

  Widget _buildPageTitle(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.transaction_title),
      key: const ValueKey('transaction_title'),
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
        color: context.ccColorScheme.onPrimary,
        fontWeight: CcTypographyParams.bold,
        fontSize: context.respFontSize(16),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSubmitButton(context),
        const CcSpaceXS(),
        _buildReportButton(context),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;
      final activeColor = _getTabColor(context, selectedIndex);

      return CcIconButton.bouncing(
        onTap: () => _submitCurrentForm(context),
        bgColor: Colors.white.withOpacity(0.15),
        icon: Icon(
          Icons.check_rounded,
          size: context.respIconSize(baseSize: 22),
          color: activeColor,
        ),
      );
    });
  }

  Widget _buildReportButton(BuildContext context) {
    return CcIconButton.bouncing(
      onTap: () => _openReport(context),
      icon: Icon(
        Icons.bar_chart_rounded,
        size: context.respIconSize(baseSize: 28),
        color: context.ccColorScheme.onPrimary,
      ),
      tooltip: el.tr(CcLocaleKeys.report_title),
    );
  }

  // ===========================================================================
  // CONTENT SECTION
  // ===========================================================================

  Widget _buildTransactionContent(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = context.respDim(200) + topPadding;
    final tabBarHeight = context.respDim(130);
    final overlap = tabBarHeight / 2;

    return Column(
      children: [
        SizedBox(height: headerHeight - overlap),
        _buildTabBar(context),
        const CcSpaceSM(),
        _buildTabBarView(context),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      height: context.respDim(60),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.respDim(20)),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(0.12),
            blurRadius: context.respDim(12),
            offset: Offset(0, context.respDim(6)),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.respDim(4)),
      child: Obx(() => _buildActualTabBar(context, scheme)),
    );
  }

  Widget _buildActualTabBar(BuildContext context, ColorScheme scheme) {
    final selectedIndex = controller.selectedTabIndex.value;
    final activeColor = _getTabColor(context, selectedIndex);

    return TabBar(
      onTap: controller.setTabIndex,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      indicator: BoxDecoration(
        color: activeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(context.respDim(16)),
      ),
      labelColor: activeColor,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: context.ccTextTheme.labelMedium?.copyWith(
        fontWeight: CcTypographyParams.bold,
        fontSize: context.respFontSize(CcTypographyParams.labelMedium),
      ),
      labelPadding: EdgeInsets.zero,
      tabs: [
        Tab(text: el.tr(CcLocaleKeys.transaction_expense_slip)),
        Tab(text: el.tr(CcLocaleKeys.transaction_income_slip)),
        Tab(text: el.tr(CcLocaleKeys.transaction_record_transfer)),
      ],
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;
      final activeColor = _getTabColor(context, selectedIndex);
      final topColor = activeColor.withAlpha(5);
      final bottomColor = activeColor.withAlpha(10);

      return Expanded(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topColor, bottomColor],
                  ),
                ),
              ),
            ),
            TabBarView(
              children: [
                ExpenseForm(onSaved: controller.refreshData),
                IncomeForm(onSaved: controller.refreshData),
                TransferForm(onSaved: controller.refreshData),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ===========================================================================
  // LOGIC & UTILS
  // ===========================================================================

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

  Color _getTabColor(BuildContext context, int index) {
    return switch (index) {
      0 => context.ccColorScheme.error,
      2 => context.ccColorScheme.secondary,
      _ => PrjColors.success,
    };
  }
}
