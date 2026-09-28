import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/report_controller.dart';
import 'ai_advice_section.dart';
import 'report_daily_list.dart';

/// Daily-detail block of the report body: the edit-mode toggle row, the grouped
/// daily transaction list and the AI advice section below it. Hosted by
/// [ReportDailyDetailPage], whose app bar carries the page title.
class ReportDailyDetailSection extends StatelessWidget {
  const ReportDailyDetailSection({super.key, required this.controller});

  final ReportController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const CcSpaceSM(),
        Obx(
          () => ReportDailyList(
            transactions: controller.dailyListTransactions,
            includeInvestmentAndLiability:
                controller.userLevel.status.value.canUseInvestment ||
                controller.userLevel.status.value.canUseLiability,
            isEditMode: controller.isEditMode.value,
          ),
        ),
        const CcSpaceSM(),
        AiAdviceSection(controller: controller),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final hasData = controller.dailyListTransactions.isNotEmpty;
      return Row(
        children: [
          const Spacer(),
          if (hasData)
            KeyedSubtree(
              key: controller.dailyDetailKey,
              child: CcIconButton.bouncing(
                icon: Icon(
                  controller.isEditMode.value
                      ? Icons.close_rounded
                      : Icons.edit_rounded,
                  size: context.respIconSize(baseSize: 20),
                  color: context.ccColorScheme.primary,
                ),
                tooltip: controller.isEditMode.value
                    ? el.tr(CcLocaleKeys.common_done)
                    : el.tr(CcLocaleKeys.common_edit),
                onTap: controller.toggleEditMode,
              ),
            ),
        ],
      );
    });
  }
}
