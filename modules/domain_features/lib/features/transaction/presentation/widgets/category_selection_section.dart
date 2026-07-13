import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';

class CategorySelectionSection extends StatefulWidget {
  final Function(CategoryEntity)? onCategorySelected;
  final Color activeColor;

  /// Which categories to offer: [CategoryType.expense] or
  /// [CategoryType.income].
  final String type;

  /// Pre-select (and report) the first category once loaded.
  final bool autoSelectFirst;

  const CategorySelectionSection({
    super.key,
    this.onCategorySelected,
    this.activeColor = PrjColors.primary,
    this.type = CategoryType.expense,
    this.autoSelectFirst = false,
  });

  @override
  State<CategorySelectionSection> createState() =>
      _CategorySelectionSectionState();
}

class _CategorySelectionSectionState extends State<CategorySelectionSection> {
  List<CategoryEntity> _categories = const [];
  String? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;
    setState(() {
      result.when(
        (categories) => _categories = categories
            .where((c) => c.isEnabled && c.type == widget.type)
            .toList(),
        (_) {},
      );
      _isLoading = false;
    });
    if (widget.autoSelectFirst &&
        _selectedCategoryId == null &&
        _categories.isNotEmpty) {
      setState(() => _selectedCategoryId = _categories.first.id);
      widget.onCategorySelected?.call(_categories.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
          ),
          child: CcText(
            el.tr(CcLocaleKeys.transaction_category),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: context.respFontSize(CcTypographyParams.labelMedium),
            ),
          ),
        ),
        const CcSpaceSM(),
        if (_isLoading)
          SizedBox(
            height: context.respDim(80),
            child: const Center(child: CircularProgressIndicator()),
          )
        else
          _buildCategoryList(context),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(95),
      builder: (scrollController) => ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const CcSpaceSM(),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryId == category.id;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryId = category.id);
              widget.onCategorySelected?.call(category);
            },
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
                          ? widget.activeColor
                          : context.ccColorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: CcIcon(
                        icon: iconDataFromCode(
                          category.iconCode,
                          fontFamily: category.iconFamily,
                        ),
                        size: context.respIconSize(baseSize: 22),
                        color: isSelected ? context.ccColorScheme.onPrimary : context.ccColorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const CcSpaceXS(),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style:
                        (context.ccTextTheme.labelMedium ?? const TextStyle())
                            .copyWith(
                              fontSize: context.respFontSize(
                                CcTypographyParams.labelSmall,
                              ),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? widget.activeColor
                                  : context.ccColorScheme.onSurfaceVariant,
                            ),
                    child: CcText(
                      el.tr(category.nameKey),
                      textAlign: TextAlign.center,
                      align: Alignment.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
