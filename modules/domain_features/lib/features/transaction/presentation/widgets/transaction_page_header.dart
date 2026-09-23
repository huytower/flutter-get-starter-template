import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../guideline/export_guideline.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/quick_entry_mixin.dart';
import '../get_x/transaction_controller.dart';
import 'transaction_header_actions.dart';
import 'transaction_header_banner.dart';
import 'transaction_header_title.dart';

class TransactionPageHeader extends StatelessWidget {
  const TransactionPageHeader({
    required this.controller,
    this.onOpenNotification,
    this.onOpenReport,
    this.onSubmit,
    this.expenseFormController,
  });

  final TransactionController controller;
  final VoidCallback? onOpenNotification;
  final VoidCallback? onOpenReport;
  final VoidCallback? onSubmit;
  final ExpenseFormController? expenseFormController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = context.ccColorScheme;
    final assetPath = isDark
        ? 'assets/bg/bg_header_dark.webp'
        : 'assets/bg/bg_header_light.webp';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: scheme.background,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(context.respDim(16)),
            bottomRight: Radius.circular(context.respDim(16)),
          ),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildHeroForeground(context),
      ),
    );
  }

  Widget _buildHeroForeground(BuildContext context) {
    final guideline = Get.find<GuidelineController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.of(context).padding.top > 0)
          SizedBox(height: MediaQuery.of(context).padding.top),

        const CcSpaceMD(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TransactionHeaderTitle(
                controller: controller,
                quickEntryControllerFor: _quickEntryControllerFor,
              ),
              TransactionHeaderActions(
                controller: controller,
                onSubmit: onSubmit,
                onOpenReport: onOpenReport,
              ),
            ],
          ),
        ),
        const CcSpaceXS(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: TransactionHeaderBanner(
            controller: controller,
            guideline: guideline,
            expenseFormController: expenseFormController,
          ),
        ),
      ],
    );
  }

  QuickEntryMixin? _quickEntryControllerFor(TransactionTabKind tab) {
    return (tab == TransactionTabKind.expense && expenseFormController != null)
        ? expenseFormController
        : controller.getQuickEntryControllerForTab(tab);
  }
}
