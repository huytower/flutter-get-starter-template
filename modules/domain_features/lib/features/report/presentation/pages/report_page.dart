import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:cc_sdk_ui/widgets/padding/cc_padding.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/report_range.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../get_x/report_controller.dart';
import '../widgets/report_daily_list.dart';
import '../widgets/report_page_header.dart';
import '../widgets/report_range_selector.dart';
import '../widgets/trend_card.dart';

@RoutePage()
class ReportPage extends CcGetView<ReportController> {
  const ReportPage({super.key});

  @override
  bool get enableAppBar => false;

  @override
  Widget? buildContent(BuildContext context) {
    return FadePageWrapper(
      child: Stack(
        children: [
          ReportPageHeader(
            controller: controller,
            title: el.tr(CcLocaleKeys.report_title),
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          _buildReportContent(context),
        ],
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = context.respDim(170) + topPadding;
    final tabBarHeight = context.respDim(60);
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

          return Column(
            children: [
              SizedBox(height: headerHeight - overlap),
              _rangeSelector(context),
              const CcSpaceSM(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  children: [
                    const CcSpaceSM(),
                    _buildPeriodNavigation(context),
                    _buildTrendCards(context, data),
                    const CcSpaceXL(),
                    _buildDailyDetailHeader(context),
                    const CcSpaceLG(),
                    ReportDailyList(transactions: data.transactions),
                  ],
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

  Widget _buildPeriodNavigation(BuildContext context) {
    final isWeekly = controller.range.value == ReportRange.weekly;

    return CcPadding(
      Center(
        child: SizedBox(
          height: context.respDim(40),
          child: Center(
            child: isWeekly ? _buildWeeklyLabel(context) : _buildPeriodSwitcher(context),
          ),
        ),
      ),
      CcPaddingParams.SPACE_MD,
      0,
      0,
      0,
    );
  }

  Widget _buildWeeklyLabel(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.report_four_weeks_near),
      textStyle: context.ccTextTheme.titleSmall?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPeriodSwitcher(BuildContext context) {
    final onSurface = context.ccColorScheme.onSurface;
    final outline = context.ccColorScheme.outline;

    return CcRowCenter(
      children: [
        CcIconButton.bouncing(
          onTap: controller.previousPeriod,
          isEnable: controller.canPrevious,
          icon: Icon(
            Icons.chevron_left,
            color: controller.canPrevious ? onSurface : outline,
          ),
        ),
        const CcSpaceSM(),
        CcText(
          el.tr(CcLocaleKeys.report_four_weeks_near),
          textStyle: context.ccTextTheme.titleSmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const CcSpaceSM(),
        CcIconButton.bouncing(
          onTap: controller.nextPeriod,
          isEnable: controller.canNext,
          icon: Icon(
            Icons.chevron_right,
            color: controller.canNext ? onSurface : outline,
          ),
        ),
      ],
    );
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

    return Container(
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

  Widget _rangeSelector(BuildContext context) {
    return ReportRangeSelector(
      selectedRange: controller.range.value,
      onChanged: (range) => controller.selectRange(range),
    );
  }
}
