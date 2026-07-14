import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:cc_sdk_ui/widgets/padding/cc_padding.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
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
          el.tr(CcLocaleKeys.report_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
            fontSize: context.respFontSize(CcTypographyParams.titleMedium),
          ),
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
          if (controller.trendData.value == null &&
              controller.layoutStatus.value == CcLayoutStatus.loading) {
            return const CcProgressIndicator(paddingTop: 0);
          }

          final data = controller.trendData.value;
          if (data == null) return const SizedBox.shrink();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: padding),
            children: [
              const CcSpaceLG(),
              if (controller.runway.value != null) ...[
                FinancialRunwayWidget(runway: controller.runway.value!),
                const CcSpaceLG(),
              ],
              _rangeSelector(context),
              const CcSpaceLG(),
              if (controller.range.value != ReportRange.weekly)
                CcPadding(
                  Center(
                    child: SizedBox(
                      height: context.respDim(40),
                      child: Center(
                        child: CcRowCenter(
                          children: [
                            CcIconButton.bouncing(
                              onTap: controller.previousPeriod,
                              isEnable: controller.canPrevious,
                              icon: Icon(
                                Icons.chevron_left,
                                color: controller.canPrevious
                                    ? context.ccColorScheme.onSurface
                                    : context.ccColorScheme.outline,
                              ),
                            ),
                            const CcSpaceSM(),
                            CcText(
                              el.tr(CcLocaleKeys.report_four_weeks_near),
                              textStyle: context.ccTextTheme.titleSmall
                                  ?.copyWith(
                                    color:
                                        context.ccColorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const CcSpaceSM(),
                            CcIconButton.bouncing(
                              onTap: controller.nextPeriod,
                              isEnable: controller.canNext,
                              icon: Icon(
                                Icons.chevron_right,
                                color: controller.canNext
                                    ? context.ccColorScheme.onSurface
                                    : context.ccColorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  16,
                  0,
                  0,
                  0,
                ),
              if (controller.range.value == ReportRange.weekly)
                CcPadding(
                  Center(
                    child: SizedBox(
                      height: context.respDim(40),
                      child: Center(
                        child: CcText(
                          el.tr(CcLocaleKeys.report_four_weeks_near),
                          textStyle: context.ccTextTheme.titleSmall?.copyWith(
                            color: context.ccColorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  16,
                  0,
                  0,
                  0,
                ),
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
              const CcSpaceXL(),
              CcText(
                el.tr(CcLocaleKeys.report_daily_detail),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const CcSpaceLG(),
              ReportDailyList(transactions: data.transactions),
            ],
          );
        });
      },
    );
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) {
    return Container(color: context.ccColorScheme.background, child: body);
  }

  Widget _rangeSelector(BuildContext context) {
    final primaryBackground = context.ccColorScheme.primary.withValues(
      alpha: 0.15,
    );
    final primaryText = context.ccColorScheme.onPrimary;

    return CcPadding(
      SegmentedButton<ReportRange>(
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
          selectedBackgroundColor: primaryBackground,
          selectedForegroundColor: primaryText,
          side: BorderSide.none,
          textStyle: context.ccTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        onSelectionChanged: (selection) =>
            controller.selectRange(selection.first),
      ),
      8,
      0,
      0,
      8,
    );
  }
}
