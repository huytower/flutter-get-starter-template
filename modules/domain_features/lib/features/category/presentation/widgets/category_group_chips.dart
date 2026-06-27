import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/category_group_entity.dart';

/// A widget displaying a horizontal list of category group chips.
class CategoryGroupChips extends StatelessWidget {
  final List<CategoryGroupEntity> groups;
  final String? selectedGroupId;
  final Function(String?)? onGroupSelected;

  const CategoryGroupChips({
    super.key,
    required this.groups,
    this.selectedGroupId,
    this.onGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
      ),
      child: Row(
        children: [
          _buildChip(
            context,
            id: null,
            label: el.tr('common.all'), // Using existing common.all key
          ),
          ...groups.map(
            (group) =>
                _buildChip(context, id: group.id, label: el.tr(group.nameKey)),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String? id,
    required String label,
  }) {
    final isSelected = id == selectedGroupId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: CcText(
          label,
          textStyle: context.ccTextTheme.labelLarge?.copyWith(
            color: isSelected
                ? context.ccColorScheme.onPrimary
                : context.ccColorScheme.onSurfaceVariant,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) onGroupSelected?.call(id);
        },
        selectedColor: context.ccColorScheme.primary,
        backgroundColor: context.ccColorScheme.surfaceContainerHighest,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.respDim(CcCircularParams.RADIUS_MD),
          ),
        ),
      ),
    );
  }
}
