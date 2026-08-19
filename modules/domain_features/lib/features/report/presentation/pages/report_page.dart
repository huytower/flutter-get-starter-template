import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../get_x/report_controller.dart';
import '../widgets/ai_advice_section.dart';
import '../widgets/report_daily_list.dart';
import '../widgets/report_page_header.dart';
import '../widgets/report_tab_bar.dart';
import '../widgets/trend_card.dart';

/// Shared shade alpha for the Investment/Debt-Liability trend card fills — mirrors
/// [report_daily_list]'s constant of the same name/value for the same rows.
const double _inflowShadeAlpha = 0.5;

@RoutePage()
class ReportPage extends CcGetView<ReportController> {
  const ReportPage({super.key});

  @override
  bool get enableAppBar => false;

  @override
  Widget? buildContent(BuildContext context) {
    final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;

    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.3,
      tablet: 0.28,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    return DefaultTabController(
      length: 3,
      child: FadePageWrapper(
        child: Stack(
          children: [
            Obx(() {
              final hidden = controller.isHeaderHidden.value || keyboardUp;
              return AnimatedOpacity(
                opacity: hidden ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: hidden ? 0 : headerHeight,
                  // ReportPageHeader's internal Spacer/Flexible layout is
                  // only correct at the full headerHeight — feeding it the
                  // shrinking height directly (as this AnimatedContainer
                  // animates toward 0) squeezes that layout mid-animation
                  // and throws a transient RenderFlex overflow. Pin the
                  // header's own constraints to headerHeight via OverflowBox
                  // and let ClipRect clip the paint instead, so the content
                  // never sees a too-small height.
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: headerHeight,
                      maxHeight: headerHeight,
                      child: ReportPageHeader(
                        controller: controller,
                        title: el.tr(CcLocaleKeys.report_title),
                        onBackPressed: () => controller.onBack(context),
                      ),
                    ),
                  ),
                ),
              );
            }),
            _buildReportContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.3,
      tablet: 0.32,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    final tabBarHeight = context.respDim(90);
    final overlap = tabBarHeight / 2;

    return Builder(
      builder: (context) {
        final padding = context.respPadding(CcPaddingParams.SPACE_MD);
        return Obx(() {
          if (controller.trendData.value == null &&
              controller.layoutStatus.value == CcLayoutStatus.loading) {
            return _buildLoading();
          }

          final data = controller.trendData.value;
          if (data == null) return const SizedBox.shrink();

          final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;
          final hidden = controller.isHeaderHidden.value || keyboardUp;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: hidden ? 0 : headerHeight - overlap,
              ),
              ReportTabBar(controller: controller),
              const CcSpaceSM(),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    controller.onScroll(notification);
                    return false;
                  },
                  child: ListView(
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    // The report body is a bounded, finite set of sections
                    // (not an infinite feed) — a generous cacheExtent forces
                    // every section to mount eagerly instead of staying
                    // lazily unbuilt while off-screen, which is required for
                    // ReportController's scroll-to-daily-detail (a GlobalKey
                    // has no BuildContext to scroll to until its widget has
                    // actually been mounted at least once).
                    cacheExtent: 3000,
                    children: [
                      const CcSpaceSM(),
                      _buildTrendCards(context, data),
                      _buildInvestmentSection(context),
                      _buildLiabilitySection(context),
                      _buildDailyDetailHeader(context),
                      const CcSpaceLG(),
                      ReportDailyList(
                        transactions: controller.dailyListTransactions,
                      ),
                      const CcSpaceSM(),
                      AiAdviceSection(controller: controller),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildLoading() {
    return const CcProgressIndicator(paddingTop: 0);
  }

  Widget _buildTrendCards(BuildContext context, TrendDataEntity data) {
    return Column(
      children: [
        TrendCard(
          title: el.tr(CcLocaleKeys.common_expense),
          amount: data.totalExpense,
          points: data.points,
          color: context.ccColorScheme.error,
          range: controller.range.value,
          isIncome: false,
        ),
        const CcSpaceLG(),
        TrendCard(
          title: el.tr(CcLocaleKeys.common_income),
          amount: data.totalIncome,
          points: data.points,
          color: PrjColors.success,
          range: controller.range.value,
          isIncome: true,
        ),
      ],
    );
  }

  Widget _buildInvestmentSection(BuildContext context) {
    return Obx(() {
      final data = controller.investmentTrend.value;
      if (!controller.userLevel.status.value.canUseInvestment ||
          data == null ||
          (data.totalIncome == 0 && data.totalExpense == 0)) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.report_investment_title),
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceMD(),
          TrendCard(
            title: el.tr(CcLocaleKeys.report_investment_contributed),
            amount: data.totalExpense,
            points: data.points,
            color: context.ccColorScheme.investment,
            range: controller.range.value,
            isIncome: false,
            icon: Icons.eco,
          ),
          const CcSpaceLG(),
          TrendCard(
            title: el.tr(CcLocaleKeys.report_investment_returned),
            amount: data.totalIncome,
            points: data.points,
            color: context.ccColorScheme.investmentSecondary,
            range: controller.range.value,
            isIncome: true,
            icon: Icons.auto_graph_rounded,
          ),
          const CcSpaceXL(),
        ],
      );
    });
  }

  Widget _buildLiabilitySection(BuildContext context) {
    return Obx(() {
      final data = controller.loanTrend.value;
      if (!controller.userLevel.status.value.canUseDebtLoan ||
          data == null ||
          (data.totalIncome == 0 && data.totalExpense == 0)) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.report_liability_title),
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceMD(),
          TrendCard(
            title: el.tr(CcLocaleKeys.report_liability_out),
            amount: data.totalExpense,
            points: data.points,
            color: context.ccColorScheme.debtLoanSecondary,
            range: controller.range.value,
            isIncome: false,
          ),
          const CcSpaceLG(),
          TrendCard(
            title: el.tr(CcLocaleKeys.report_liability_in),
            amount: data.totalIncome,
            points: data.points,
            color: context.ccColorScheme.debtLoan,
            range: controller.range.value,
            isIncome: true,
          ),
          const CcSpaceXL(),
        ],
      );
    });
  }

  Widget _buildDailyDetailHeader(BuildContext context) {
    return KeyedSubtree(
      key: controller.dailyDetailKey,
      child: CcText(
        el.tr(CcLocaleKeys.report_daily_detail),
        textStyle: context.ccTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) {
    final primaryColor = context.ccColorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.10),
            context.ccColorScheme.background,
          ],
        ),
      ),
      child: body,
    );
  }
}
