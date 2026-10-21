import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/navigation/domain_router.gr.dart';

/// Shortcut button row ("See all" + right chevron icon) to view full insights on the Report page.
class BudgetInsightsSeeMoreShortcut extends StatelessWidget {
  final VoidCallback? onTap;

  const BudgetInsightsSeeMoreShortcut({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final handleTap =
        onTap ?? () => context.router.push(const BudgetInsightsListRoute());

    return Padding(
      padding: EdgeInsets.only(
        top: context.respDim(4),
        bottom: context.respDim(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CcTextButton(
            text: el.tr(CcLocaleKeys.budget_see_all),
            onTap: handleTap,
          ),
          const CcSpaceXS(),
          CcBouncing(
            onTap: handleTap,
            child: Icon(
              Icons.chevron_right_rounded,
              size: context.respIconSize(baseSize: 20),
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
