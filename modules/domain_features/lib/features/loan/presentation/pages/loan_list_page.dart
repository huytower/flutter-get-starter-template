import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../get_x/loan_list_controller.dart';
import '../widgets/loan_balance_list.dart';

@RoutePage()
class LoanListPage extends CcGetView<LoanListController> {
  const LoanListPage({super.key});

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
        el.tr(CcLocaleKeys.loan_list_title),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(() {
      // Snapshot via toList() so the read happens synchronously inside this
      // builder (RxList mutations are only trackable through List-method
      // calls made here — LoanBalanceList is a separate widget whose own
      // build() runs outside this closure, so reads inside it wouldn't
      // register a subscription and Obx would throw "no observables found").
      final balances = controller.loans.toList();
      return LoanBalanceList(
        balances: balances,
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        emptyMessage: el.tr(CcLocaleKeys.loan_empty_state),
        onLoanSelected: (loanId) {
          final balance = balances.firstWhere((b) => b.loan.id == loanId);
          context.router.push(LoanDetailRoute(loan: balance));
        },
      );
    });
  }
}
