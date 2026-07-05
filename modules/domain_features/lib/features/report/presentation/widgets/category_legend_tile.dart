import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/icon_utils.dart';
import '../../../../core/util/money_format.dart';
import '../../domain/entities/category_spending_entity.dart';

/// One row under the pie chart: colour swatch + category icon/name on the left,
/// amount + percentage share on the right.
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            iconDataFromCode(slice.iconCode, fontFamily: slice.iconFamily),
            size: 18,
            color: context.ccColorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CcText(
              el.tr(slice.nameKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: context.ccTextTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          CcText(
            formatVndShort(slice.amount),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: CcText(
              '${slice.percent}%',
              textAlign: TextAlign.right,
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
