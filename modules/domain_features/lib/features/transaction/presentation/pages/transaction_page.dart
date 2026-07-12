import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../get_x/transaction_controller.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_form.dart';
import '../widgets/transaction_wallet_summary.dart';
import '../widgets/transfer_form.dart';
import 'transaction_history_page.dart';

@RoutePage()
class TransactionPage extends CcGetView<TransactionController> {
  TransactionPage({super.key});

  final _expenseFormKey = GlobalKey<ExpenseFormState>();
  final _incomeFormKey = GlobalKey<IncomeFormState>();
  final _transferFormKey = GlobalKey<TransferFormState>();

  @override
  bool get enableAppBar => true;

  @override
  bool get enableBottomNavigationBar => false;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return _buildAppBarWithContext(context);
  }

  PreferredSizeWidget _buildAppBarWithContext(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      title: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: controller.showWalletSummaryTemporarily.value
              ? const TransactionWalletSummary(
                  key: ValueKey('wallet_summary'),
                )
              : CcText(
                  el.tr(CcLocaleKeys.transaction_title),
                  key: const ValueKey('transaction_title'),
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    color: context.ccColorScheme.onPrimary,
                    fontWeight: CcTypographyParams.bold,
                    letterSpacing: 1.2,
                    fontSize: context.respFontSize(16),
                  ),
                ),
        );
      }),
      actions: [
        Obx(
          () => IconButton(
            onPressed: _submitCurrentForm,
            icon: Icon(
              Icons.check_circle_outline_rounded,
              size: context.respIconSize(baseSize: 24),
              color: _getTabColor(
                context,
                controller.selectedTabIndex.value,
              ),
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: context.respDim(40),
              minHeight: context.respDim(40),
            ),
          ),
        ),
        const CcSpaceXS(),
        InkWell(
          onTap: () => _openHistory(context),
          borderRadius: BorderRadius.circular(context.respDim(20)),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: context.respIconSize(baseSize: 18),
                  color: context.ccColorScheme.onPrimary,
                ),
                const CcSpaceXS(),
                CcText(
                  el.tr(CcLocaleKeys.transaction_history),
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: context.ccColorScheme.onPrimary,
                    fontWeight: CcTypographyParams.bold,
                    fontSize: context.respFontSize(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Builder(
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: FadePageWrapper(
            child: Column(
              children: [
                const CcSpaceMD(),
                _buildTabBar(context),
                const CcSpaceSM(),
                Expanded(
                  child: TabBarView(
                    children: [
                      ExpenseForm(
                        onSaved: controller.refreshData,
                        key: _expenseFormKey,
                      ),
                      IncomeForm(
                        onSaved: controller.refreshData,
                        key: _incomeFormKey,
                      ),
                      TransferForm(
                        onSaved: controller.refreshData,
                        key: _transferFormKey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionHistoryPage(
          initialTab: controller.selectedTabIndex.value,
        ),
      ),
    );
  }

  void _submitCurrentForm() {
    controller.flashWalletSummary();
    switch (controller.selectedTabIndex.value) {
      case 0:
        _expenseFormKey.currentState?.submitForm();
        break;
      case 1:
        _incomeFormKey.currentState?.submitForm();
        break;
      case 2:
        _transferFormKey.currentState?.submitForm();
        break;
    }
  }

  Color _getTabColor(BuildContext context, int index) {
    return switch (index) {
      0 => context.ccColorScheme.error,
      2 => context.ccColorScheme.secondary,
      _ => PrjColors.success,
    };
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      height: context.respDim(48),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.respDim(25)),
      ),
      child: Obx(() {
        return TabBar(
          onTap: controller.setTabIndex,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: context.ccColorScheme.surface,
            borderRadius: BorderRadius.circular(context.respDim(25)),
            boxShadow: [
              BoxShadow(
                color: context.ccColorScheme.onSurface.withOpacity(0.05),
                blurRadius: context.respDim(4),
                offset: Offset(0, context.respDim(2)),
              ),
            ],
          ),
          labelColor: _getTabColor(context, controller.selectedTabIndex.value),
          unselectedLabelColor: context.ccColorScheme.onSurfaceVariant,
          labelStyle: context.ccTextTheme.titleSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            fontSize: context.respFontSize(12),
          ),
          labelPadding: EdgeInsets.zero,
          tabs: [
            Tab(text: el.tr(CcLocaleKeys.transaction_expense_slip)),
            Tab(text: el.tr(CcLocaleKeys.transaction_income_slip)),
            Tab(text: el.tr(CcLocaleKeys.transaction_record_transfer)),
          ],
        );
      }),
    );
  }
}
