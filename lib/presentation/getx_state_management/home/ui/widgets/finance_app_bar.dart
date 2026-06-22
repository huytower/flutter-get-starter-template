import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'expense_button.dart';
import 'income_button.dart';

class FinanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FinanceAppBar({
    super.key,
    this.onHistoryPressed,
    this.onExpensePressed,
    this.onIncomePressed,
    this.onApprovePressed,
  });

  final VoidCallback? onHistoryPressed;
  final VoidCallback? onExpensePressed;
  final VoidCallback? onIncomePressed;
  final VoidCallback? onApprovePressed;

  static const double _appBarHeight = kToolbarHeight + 16;

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    // Responsive icon size using cc_sdk extension: 24px base, scales up to 32px on larger screens
    final iconSize = context.respIconSize();
    final horizontalPadding = context.respPadding(CcPaddingParams.PAGE_SM);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 2,
      toolbarHeight: _appBarHeight,
      shadowColor: context.isDarkMode
          ? CcBaseColors.transparent
          : CcBaseColors.neutral10,
      leading: Padding(
        padding: EdgeInsets.only(left: horizontalPadding),
        child: IconButton(
          icon: Icon(Icons.history, color: context.ccColorScheme.onSurface),
          onPressed: onHistoryPressed ?? () {},
          iconSize: iconSize,
        ),
      ),
      leadingWidth: iconSize + horizontalPadding + 16,
      title: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpenseButton(onTap: onExpensePressed ?? () {}),
            const CcSpaceXS(),
            IncomeButton(onTap: onIncomePressed ?? () {}),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: horizontalPadding),
          child: IconButton(
            icon: Icon(
              Icons.check_circle,
              color: context.ccColorScheme.onSurface,
            ),
            onPressed: onApprovePressed ?? () {},
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }
}
