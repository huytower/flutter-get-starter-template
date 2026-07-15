import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';

class BudgetLimitCategorySelector extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final ValueChanged<CategoryEntity> onCategorySelected;
  final void Function(ScrollController)? onScrollControllerCreated;

  const BudgetLimitCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.onScrollControllerCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          el.tr(CcLocaleKeys.budget_category),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: context.respFontSize(12),
          ),
        ),
        const CcSpaceSM(),
        HorizontalFadeScrollView(
          height: context.respDim(85),
          builder: (scrollController) {
            onScrollControllerCreated?.call(scrollController);
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () => onCategorySelected(cat),
                  child: SizedBox(
                    width: context.respDim(68),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: context.respDim(52),
                          height: context.respDim(52),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.ccColorScheme.primary
                                : context.ccColorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: CcIcon(
                              icon: iconDataFromCode(
                                cat.iconCode,
                                fontFamily: cat.iconFamily,
                              ),
                              size: context.respIconSize(baseSize: 22),
                              color: isSelected
                                  ? context.ccColorScheme.onPrimary
                                  : context.ccColorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const CcSpaceXS(),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          style:
                              (context.ccTextTheme.bodySmall ??
                                      const TextStyle())
                                  .copyWith(
                                    fontSize: context.respFontSize(9),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? context.ccColorScheme.primary
                                        : context
                                              .ccColorScheme
                                              .onSurfaceVariant,
                                  ),
                          child: Text(
                            el.tr(cat.nameKey),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
