import 'package:auto_route/annotations.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../domain/entities/loan_balance_entity.dart';
import '../../domain/entities/loan_entity.dart';
import '../get_x/loan_detail_controller.dart';
import '../widgets/loan_balance_card.dart';
import '../widgets/loan_history_section.dart';
import '../widgets/loan_repay_form.dart';
import '../widgets/loan_schedule_info.dart';

/// Full detail of one loan/lend record: balance, schedule, transaction
/// history, and the Trả nợ/Thu nợ (repay/collect) form.
@RoutePage()
class LoanDetailPage extends StatelessWidget with CcViewConfigMixin {
  final LoanBalanceEntity loan;

  const LoanDetailPage({super.key, required this.loan});

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
      title: CcText(
        "",
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    final controller = Get.put(getIt<LoanDetailController>());
    controller.load(loan);

    return Obx(() {
      final current = controller.loan.value ?? loan.loan;
      final accentColor = current.isBorrow
          ? PrjColors.warning
          : context.ccColorScheme.secondary;

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          controller.hideKeypad();
        },
        child: Column(
          children: [
            Expanded(
              child: _buildScrollableContent(
                context,
                controller,
                current,
                accentColor,
              ),
            ),
            if (controller.showKeypad.value)
              MoneyKeypadPanel(
                onKeyPress: controller.handleKeyPress,
                onDelete: controller.handleDelete,
                onClear: () => controller.amountStr.value = '0',
                suggestions: MoneyConstants.quickAmounts,
                onSuggestion: (value) =>
                    controller.amountStr.value = value.toString(),
                onDone: controller.hideKeypad,
                activeColor: accentColor,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildScrollableContent(
    BuildContext context,
    LoanDetailController controller,
    LoanEntity current,
    Color accentColor,
  ) {
    return SingleChildScrollView(
      controller: controller.scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.PAGE_LG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoanBalanceCard(
            controller: controller,
            current: current,
            accentColor: accentColor,
          ),
          const CcSpaceLG(),
          LoanScheduleInfo(current: current, accentColor: accentColor),
          if (!controller.isSettled) ...[
            const CcSpaceXL(),
            LoanRepayForm(
              controller: controller,
              current: current,
              accentColor: accentColor,
            ),
          ],
          const CcSpaceXL(),
          LoanHistorySection(controller: controller),
        ],
      ),
    );
  }
}
