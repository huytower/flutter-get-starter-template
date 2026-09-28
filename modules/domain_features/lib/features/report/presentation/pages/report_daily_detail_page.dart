import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../get_x/report_controller.dart';
import '../widgets/report_daily_detail_section.dart';

/// Detail page hosting [ReportDailyDetailSection] — pushed from the report
/// page's "Chi tiết theo ngày" row.
@RoutePage()
class ReportDailyDetailPage extends StatelessWidget {
  const ReportDailyDetailPage({super.key});

  @override
  Widget build(BuildContext context) => const _ReportDailyDetailView();
}

class _ReportDailyDetailView extends CcGetView<ReportController> {
  const _ReportDailyDetailView();

  @override
  bool get enableBottomNavigationBar => false;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      leading: CcBackBtn(onTap: () => controller.onBack(context)),
      title: Center(
        child: CcText(
          el.tr(CcLocaleKeys.report_daily_detail),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ),
      actions: [
        Obx(() {
          if (!controller.userLevel.status.value.isVip) {
            return const SizedBox.shrink();
          }
          return CcIconButton.bouncing(
            onTap: () => controller.generateAiAdvice(context),
            tooltip: el.tr(CcLocaleKeys.report_ai_advice_title),
            icon: Icon(
              Icons.auto_awesome,
              color: context.ccColorScheme.onPrimary,
              size: context.respIconSize(baseSize: 20),
            ),
          );
        }),
        const CcSpaceXS(),
        Obx(
          () => CcIconButton.bouncing(
            onTap: controller.toggleEditMode,
            tooltip: controller.isEditMode.value
                ? el.tr(CcLocaleKeys.common_done)
                : el.tr(CcLocaleKeys.common_edit),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                controller.isEditMode.value
                    ? Icons.check_circle_outline_rounded
                    : Icons.edit_rounded,
                key: ValueKey(controller.isEditMode.value),
                color: context.ccColorScheme.onPrimary,
                size: context.respIconSize(baseSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.isEditMode.value,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            controller.isEditMode.value = false;
          }
        },
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_XS),
          ),
          children: [ReportDailyDetailSection(controller: controller)],
        ),
      ),
    );
  }
}
