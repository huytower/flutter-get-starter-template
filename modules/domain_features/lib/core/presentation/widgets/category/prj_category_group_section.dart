import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'prj_category_chip.dart';

/// Data model for items displayed within [PrjCategoryGroupSection].
///
/// [label] is shown as is — pass already-translated text.
class PrjCategoryGroupItem {
  final String label;
  final int iconCode;
  final String? iconFamily;
  final dynamic originalData; // To pass back the full object on toggle

  const PrjCategoryGroupItem({
    required this.label,
    required this.iconCode,
    this.iconFamily,
    this.originalData,
  });
}

/// A horizontal section representing a group of categories with a glassy background
/// and a large watermark icon.
class PrjCategoryGroupSection extends StatelessWidget {
  final List<PrjCategoryGroupItem> items;
  final bool Function(PrjCategoryGroupItem) hasEnabled;
  final void Function(PrjCategoryGroupItem) onToggle;
  final Color? accentColor;
  final IconData? watermarkIcon;

  const PrjCategoryGroupSection({
    super.key,
    required this.items,
    required this.hasEnabled,
    required this.onToggle,
    this.accentColor,
    this.watermarkIcon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = accentColor ?? context.ccColorScheme.primary;

    // Use watermarkIcon if provided, else fallback to first item's icon or generic category icon
    final backgroundIcon =
        watermarkIcon ??
        (items.isNotEmpty
            ? iconDataFromCode(
                items.first.iconCode,
                fontFamily: items.first.iconFamily,
              )
            : Icons.category_rounded);

    return CcPadding(
      ClipRRect(
        borderRadius: BorderRadius.horizontal(left: context.brMd.topLeft),
        child: CcWatermarkBackground(
          icon: backgroundIcon,
          activeColor: primary,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.respDim(18)),
            child: CcHorizontalFadeScrollView(
              height: context.respDim(45),
              builder: (controller) => ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => const CcSpaceSM(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final enabled = hasEnabled(item);
                  return PrjCategoryChip(
                    label: item.label,
                    iconCode: item.iconCode,
                    iconFamily: item.iconFamily,
                    hasEnabled: enabled,
                    onTap: () => onToggle(item),
                    accentColor: accentColor,
                  );
                },
              ),
            ),
          ),
        ),
      ),
      CcPaddingParams.SPACE_XS,
      CcPaddingParams.PAGE_SM,
      0,
      CcPaddingParams.SPACE_XS,
    );
  }
}
