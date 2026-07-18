import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../get_x/report_controller.dart';
import '../widgets/report_daily_list.dart';
import '../widgets/report_page_header.dart';
import '../widgets/report_tab_bar.dart';
import '../widgets/trend_card.dart';

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
      mobile: 0.3, // Increased to 38% for mobile to accommodate all header
      // info
      tablet: 0.28, // Tablets
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
                  child: ReportPageHeader(
                    controller: controller,
                    title: el.tr(CcLocaleKeys.report_title),
                    onBackPressed: () => Navigator.of(context).pop(),
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
      tablet: 0.28,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    // Tab bar height scaled responsively
    final tabBarHeight = context.respDim(100);
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

          // Hide the header when the body is scrolled down (or a keyboard is up).
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
                    if (notification is ScrollUpdateNotification) {
                      controller.isHeaderHidden.value =
                          notification.metrics.pixels > 8;
                    }
                    return false;
                  },
                  child: ListView(
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    children: [
                      const CcSpaceSM(),
                      _buildTrendCards(context, data),
                      const CcSpaceXL(),
                      _buildDailyDetailHeader(context),
                      const CcSpaceLG(),
                      ReportDailyList(transactions: data.transactions),
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

  Widget _buildDailyDetailHeader(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.report_daily_detail),
      textStyle: context.ccTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
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
