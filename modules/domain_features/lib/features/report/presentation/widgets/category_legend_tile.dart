import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/money_format_helper.dart';
import '../../domain/entities/category_spending_entity.dart';

class CategoryLegendTile extends StatelessWidget {
  const CategoryLegendTile({
    super.key,
    required this.slice,
    required this.color,
  });

  final CategorySpendingEntity slice;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CcSymmetricPadding(
      vertical: 4,
      child: Row(
        children: [
          Container(
            width: context.respDim(12),
            height: context.respDim(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(context.respDim(3)),
            ),
          ),
          const CcSpaceMD(),
          Expanded(
            child: CcText(
              el.tr(slice.nameKey),
              textStyle: context.ccTextTheme.bodySmall,
            ),
          ),
          CcText(
            '${slice.percent}%',
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
          const CcSpaceMD(),
          CcText(
            formatVndShort(slice.amount),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
