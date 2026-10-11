import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
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
    controller.isEditMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return _ReportView(controller: controller);
  }
}

class _ReportView extends CcGetView<ReportController> {
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

    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.26,
      tablet: 0.24,
    );
    final headerHeight = screenHeight * headerHeightFactor;

    return Obx(
      () => PopScope(
        canPop: !controller.isEditMode.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            controller.isEditMode.value = false;
            return;
          }
          if (controller.isEditMode.value) {
            controller.isEditMode.value = false;
          }
        },
        child: DefaultTabController(
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
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeightFactor = CcResponsiveHelper.getValue(
      context: context,
      mobile: 0.29,
      tablet: 0.27,
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

          final topPadding = MediaQuery.of(context).padding.top;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: hidden ? topPadding : headerHeight - overlap,
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      0,
                      padding,
                      tabBarHeight,
                    ),
                    children: [
                      const CcSpaceXS(),
                      const ReportDailyDetailShortcut(),
                      const CcSpaceSM(),
                      ReportTrendSection(controller: controller, data: data),
                      ReportInvestmentSection(controller: controller),
                      ReportLiabilitySection(controller: controller),
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
