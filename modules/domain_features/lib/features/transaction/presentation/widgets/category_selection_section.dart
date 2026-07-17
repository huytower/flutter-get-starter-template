import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/wallet_icon_helper.dart';

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
        _buildTitle(context),
        const CcSpaceSM(),
        if (_isLoading)
          SizedBox(
            height: context.respDim(90),
            child: const Center(child: CircularProgressIndicator()),
          )
        else
          _buildCategoryList(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: CcText(
        el.tr(CcLocaleKeys.transaction_category),
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: context.respFontSize(12),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(90),
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
          return _buildCategoryItem(context, category, isSelected);
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryEntity category,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategoryId = category.id);
        widget.onCategorySelected?.call(category);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                borderRadius: context.respDim(16),
                endColor: widget.activeColor.withOpacity(0.2),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(68),
            padding: EdgeInsets.all(context.respDim(10)),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.activeColor.withOpacity(0.1)
                  : scheme.onSurface.withOpacity(0.04),
              borderRadius: BorderRadius.circular(context.respDim(16)),
              border: Border.all(
                color: isSelected
                    ? widget.activeColor.withOpacity(0.2)
                    : scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryIcon(context, category, isSelected),
                const CcSpaceXS(),
                CcText(
                  el.tr(category.nameKey),
                  textAlign: TextAlign.center,
                  align: Alignment.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    fontSize: context.respFontSize(10),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? widget.activeColor
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    CategoryEntity category,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(32),
      height: context.respDim(32),
      decoration: BoxDecoration(
        color: isSelected
            ? widget.activeColor.withOpacity(0.12)
            : scheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(context.respDim(10)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected) const Positioned.fill(child: CcGlassyGradientIcon()),
          CcIcon(
            icon: iconDataFromCode(
              category.iconCode,
              fontFamily: category.iconFamily,
            ),
            size: context.respIconSize(baseSize: 18),
            color: isSelected ? widget.activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
