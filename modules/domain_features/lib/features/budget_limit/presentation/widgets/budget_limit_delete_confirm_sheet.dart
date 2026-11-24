import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/budget/budget_name_helper.dart';
import '../../domain/entities/budget_limit_entity.dart';

class BudgetLimitDeleteConfirmSheet extends StatelessWidget {
  const BudgetLimitDeleteConfirmSheet({
    super.key,
    required this.budget,
    required this.onDelete,
  });

  final BudgetLimitEntity budget;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    // Scrolls in landscape (short window) instead of overflowing.
    return CcLandscapeScrollable(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(context.respDim(14)),
                  decoration: BoxDecoration(
                    color: scheme.error.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: scheme.error,
                    size: context.respIconSize(baseSize: 28),
                  ),
                ),
              ),
              const CcSpaceMD(),
              CcText(
                el.tr(PrjLocaleKeys.budget_delete_title),
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const CcSpaceSM(),
              CcText(
                el.tr(
                  PrjLocaleKeys.budget_delete_confirm,
                  namedArgs: {
                    'name': BudgetNameHelper.getDisplayName(
                      name: budget.name,
                      categoryNameKey: null,
                    ),
                  },
                ),
                align: Alignment.center,
                maxLines: 5,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const CcSpaceLG(),
              Row(
                children: [
                  Expanded(
                    child: CcBaseButton(
                      title: el.tr(PrjLocaleKeys.common_cancel),
                      bgColor: [
                        scheme.surfaceContainerHighest,
                        scheme.surfaceContainerHighest,
                      ],
                      textColor: scheme.onSurface,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const CcSpaceMD(),
                  Expanded(
                    child: CcBaseButton(
                      title: el.tr(PrjLocaleKeys.common_delete),
                      bgColor: [scheme.error, scheme.error],
                      textColor: scheme.onError,
                      onTap: () {
                        Navigator.of(context).pop();
                        onDelete();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
