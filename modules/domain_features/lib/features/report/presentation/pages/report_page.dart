import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/get_x/prj_get_view.dart';
import '../get_x/report_controller.dart';
import '../widgets/report_daily_detail_shortcut.dart';
import '../widgets/report_investment_section.dart';
import '../widgets/report_liability_section.dart';
import '../widgets/report_page_header.dart';
import '../widgets/report_tab_bar.dart';
import '../widgets/report_trend_section.dart';

@RoutePage()
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final ReportController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ReportController>()) {
      Get.put(getIt<ReportController>());
    }
    controller = Get.find<ReportController>();
    // Ensure edit mode is always off when entering the page.
    controller.hasEditMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return _ReportView(controller: controller);
  }
}

class _ReportView extends PrjGetView<ReportController> {
  const _ReportView({required this.controller});

  @override
  final ReportController controller;

  @override
  bool get enableAppBar => false;

  @override
  bool get useSafeArea => false;

  @override
  Widget? buildContent(BuildContext context) {
    final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;

    final headerHeight = context.respHeaderHeight(0.26);

    return Obx(
      () => PopScope(
        canPop: !controller.hasEditMode.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            controller.hasEditMode.value = false;
            return;
          }
          if (controller.hasEditMode.value) {
            controller.hasEditMode.value = false;
          }
        },
        child: DefaultTabController(
          length: 3,
          child: CcFadePageWrapper(
            child: Stack(
              children: [
                Obx(() {
                  final hidden = controller.hasHeaderHidden.value || keyboardUp;
                  return AnimatedOpacity(
                    opacity: hidden ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: hidden ? 0 : headerHeight,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: headerHeight,
                          maxHeight: headerHeight,
                          child: ReportPageHeader(
                            controller: controller,
                            title: el.tr(PrjLocaleKeys.report_title),
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
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    final headerHeight = context.respHeaderHeight(0.29);

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
          final hidden = controller.hasHeaderHidden.value || keyboardUp;

          final topPadding = MediaQuery.of(context).padding.top;

          // Landscape tablet: the tab bar stays at the content width while the
          // cards below use the wider two-column block, laid out as pairs
          // (expense | income, contributed | returned, ...) — see
          // ReportCardPair. Phones and portrait tablets: one capped column.
          final wide = CcTwoColumn.shouldUse(context);
          final sections = <Widget>[
            const CcSpaceXS(),
            const ReportDailyDetailShortcut(),
            const CcSpaceSM(),
            ReportTrendSection(controller: controller, data: data),
            ReportInvestmentSection(controller: controller),
            ReportLiabilitySection(controller: controller),
          ];

          final content = Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: hidden ? topPadding : headerHeight - overlap,
              ),
              wide
                  ? CcMaxWidth.content(
                      child: ReportTabBar(controller: controller),
                    )
                  : ReportTabBar(controller: controller),
              const CcSpaceSM(),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    controller.onScroll(notification);
                    return false;
                  },
                  child: ListView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      0,
                      padding,
                      tabBarHeight,
                    ),
                    children: wide
                        ? [
                            CcMaxWidth(
                              maxWidth: CcTwoColumn.defaultMaxWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: sections,
                              ),
                            ),
                          ]
                        : sections,
                  ),
                ),
              ),
            ],
          );
          return wide ? content : CcMaxWidth.content(child: content);
        });
      },
    );
  }

  Widget _buildLoading() {
    return const CcProgressIndicator(paddingTop: 0);
  }
}
