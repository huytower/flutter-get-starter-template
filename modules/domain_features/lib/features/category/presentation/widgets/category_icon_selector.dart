import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class CategoryIconSelector extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIconCode;
  final ValueChanged<int> onIconSelected;

  const CategoryIconSelector({
    super.key,
    required this.icons,
    required this.selectedIconCode,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Wrap(
      spacing: context.respDim(10),
      runSpacing: context.respDim(10),
      children: icons.map((icon) {
        final isSelected = selectedIconCode == icon.codePoint;
        return GestureDetector(
          onTap: () => onIconSelected(icon.codePoint),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: context.respDim(46),
            height: context.respDim(46),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary
                  : scheme.surfaceContainerHighest,
              borderRadius: context.brMd,
            ),
            child: Icon(
              icon,
              size: context.respIconSize(baseSize: 22),
              color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }
}
