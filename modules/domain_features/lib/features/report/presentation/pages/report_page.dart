import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/gradient_app_bar.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/report_range.dart';
import '../get_x/report_controller.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/spending_pie_chart.dart';

/// Reporting screen: a spending-share donut for the selected range plus a
/// 6-month income-vs-expense trend.
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
        return ListView(
          padding: EdgeInsets.all(padding),
          children: [
            _rangeSelector(context),
            SizedBox(height: padding),
            _card(
              context,
              title: el.tr(CcLocaleKeys.report_spending_proportion),
              child: Obx(() {
                if (controller.spending.isEmpty) {
                  return _emptyHint(
                    context,
                    el.tr(CcLocaleKeys.report_no_expense),
                  );
                }
                return SpendingPieChart(
                  slices: controller.spending.toList(),
                  total: controller.rangeExpense,
                );
              }),
            ),
            SizedBox(height: padding),
            _card(
              context,
              title: el.tr(CcLocaleKeys.report_monthly_chart),
              child: Obx(
                () => MonthlyBarChart(months: controller.monthly.toList()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _rangeSelector(BuildContext context) {
    return Obx(
      () => SegmentedButton<ReportRange>(
        segments: [
          ButtonSegment(
            value: ReportRange.thisWeek,
            label: Text(el.tr(CcLocaleKeys.report_this_week)),
          ),
          ButtonSegment(
            value: ReportRange.thisMonth,
            label: Text(el.tr(CcLocaleKeys.report_this_month)),
          ),
        ],
        selected: {controller.range.value},
        showSelectedIcon: false,
        onSelectionChanged: (selection) =>
            controller.selectRange(selection.first),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.ccColorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            title,
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _emptyHint(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CcText(
          message,
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
