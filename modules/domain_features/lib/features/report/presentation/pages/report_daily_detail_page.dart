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
    return AppBar(
      backgroundColor: context.ccColorScheme.surface,
      elevation: 0,
      centerTitle: true,
      leading: CcBackBtn(onTap: () => Navigator.of(context).maybePop()),
      title: CcText(
        el.tr(CcLocaleKeys.report_daily_detail),
        textStyle: context.ccTextTheme.titleMedium,
      ),
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
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          children: [ReportDailyDetailSection(controller: controller)],
        ),
      ),
    );
  }
}
