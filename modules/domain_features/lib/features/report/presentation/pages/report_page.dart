import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/util/gradient_app_bar.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/report_range.dart';
import '../get_x/report_controller.dart';
import '../widgets/financial_runway_widget.dart';
import '../widgets/report_daily_list.dart';
import '../widgets/trend_card.dart';

@RoutePage()
class ReportPage extends CcGetView<ReportController> {
  const ReportPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      title: CcText(
        el.tr(CcLocaleKeys.report_title),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Builder(
      builder: (context) {
        final padding = context.respPadding(CcPaddingParams.SPACE_MD);
        return Obx(() {
          if (controller.trendData.value == null && controller.layoutStatus.value == CcLayoutStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = controller.trendData.value;
          if (data == null) return const SizedBox.shrink();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: padding),
            children: [
              if (controller.runway.value != null) ...[
                FinancialRunwayWidget(runway: controller.runway.value!),
                const SizedBox(height: 16),
              ],
              _rangeSelector(context),
              const SizedBox(height: 16),
              if (controller.range.value != ReportRange.weekly)
                _navigationHeader(context),
              if (controller.range.value == ReportRange.weekly)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: CcText(
                      el.tr(CcLocaleKeys.report_four_weeks_near),
                      textStyle: context.ccTextTheme.labelSmall?.copyWith(
                        color: context.ccColorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              TrendCard(
                title: el.tr(CcLocaleKeys.common_expense),
                amount: data.totalExpense,
                points: data.points,
                color: context.ccColorScheme.error,
                range: controller.range.value,
                isIncome: false,
              ),
              const SizedBox(height: 16),
              TrendCard(
                title: el.tr(CcLocaleKeys.common_income),
                amount: data.totalIncome,
                points: data.points,
                color: PrjColors.success,
                range: controller.range.value,
                isIncome: true,
              ),
              const SizedBox(height: 32),
              CcText(
                el.tr(CcLocaleKeys.report_daily_detail),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ReportDailyList(transactions: data.transactions),
            ],
          );
        });
      },
    );
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) {
    return Container(
      color: CcContextExtension(context).isDarkMode ? const Color(0xFF1A1A1A) : context.ccColorScheme.background,
      child: body,
    );
  }

  Widget _rangeSelector(BuildContext context) {
    final pinkBackground = PrjColors.pink.withValues(alpha: 0.15);
    final pinkText = PrjColors.pink;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SegmentedButton<ReportRange>(
        segments: [
          ButtonSegment(
            value: ReportRange.weekly,
            label: Text(el.tr(CcLocaleKeys.report_weekly)),
          ),
          ButtonSegment(
            value: ReportRange.monthly,
            label: Text(el.tr(CcLocaleKeys.report_three_months)),
          ),
          ButtonSegment(
            value: ReportRange.yearly,
            label: Text(el.tr(CcLocaleKeys.report_yearly)),
          ),
        ],
        selected: {controller.range.value},
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          selectedBackgroundColor: pinkBackground,
          selectedForegroundColor: pinkText,
          side: BorderSide.none,
          textStyle: context.ccTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        onSelectionChanged: (selection) =>
            controller.selectRange(selection.first),
      ),
    );
  }

  Widget _navigationHeader(BuildContext context) {
    final data = controller.trendData.value;
    if (data == null || data.points.isEmpty) return const SizedBox.shrink();

    String label = "";
    if (controller.range.value == ReportRange.monthly) {
      label = "${data.points.first.label} - ${data.points.last.label}";
    } else if (controller.range.value == ReportRange.yearly) {
      label = "${data.points.first.label} - ${data.points.last.label}";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.canPrevious ? controller.previousPeriod : null,
            icon: Icon(Icons.chevron_left,
              color: controller.canPrevious ? context.ccColorScheme.onSurface : context.ccColorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          CcText(
            label,
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: controller.canNext ? controller.nextPeriod : null,
            icon: Icon(Icons.chevron_right,
              color: controller.canNext ? context.ccColorScheme.onSurface : context.ccColorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
