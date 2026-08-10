import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/wallet_icon_helper.dart';

class CategorySelectionSection extends StatefulWidget {
  final Function(CategoryEntity)? onCategorySelected;
  final Color activeColor;

  /// Which categories to offer: [CategoryType.expense] or
  /// [CategoryType.income].
  final String type;

  /// When non-null, further restricts [type]'s categories to these
  /// `groupId`s — e.g. the Loan form passes only the Borrow or Lend
  /// `debt_loan` group depending on the selected direction. Null (the
  /// default) leaves every enabled category of [type] unfiltered.
  final List<String>? groupIds;

  /// Pre-select (and report) the first category once loaded.
  final bool autoSelectFirst;

  /// Overrides the section title (defaults to the localized "Category"
  /// label) — e.g. the Loan form's Đi vay direction relabels this "Hình
  /// thức vay" since it's picking a loan type, not a spending category.
  final String? title;

  /// Pre-select this category id once loaded (e.g. editing a transaction
  /// that already has a category). Takes priority over [autoSelectFirst].
  final String? initialSelectedCategoryId;

  const CategorySelectionSection({
    super.key,
    this.onCategorySelected,
    this.activeColor = PrjColors.primary,
    this.type = CategoryType.expense,
    this.groupIds,
    this.autoSelectFirst = false,
    this.title,
    this.initialSelectedCategoryId,
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
    _selectedCategoryId = widget.initialSelectedCategoryId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;
    List<CategoryEntity> allCategories = const [];
    setState(() {
      result.when((categories) {
        allCategories = categories;
        // Create index map to preserve seed order
        final seedIndexMap = <String, int>{};
        for (int i = 0; i < CategorySeed.categories.length; i++) {
          seedIndexMap[CategorySeed.categories[i].id] = i;
        }

        _categories =
            categories
                .where(
                  (c) =>
                      c.isEnabled &&
                      c.type == widget.type &&
                      (widget.groupIds == null ||
                          widget.groupIds!.contains(c.groupId)),
                )
                .toList()
              ..sort((a, b) {
                final indexA = seedIndexMap[a.id] ?? 999;
                final indexB = seedIndexMap[b.id] ?? 999;
                return indexA.compareTo(indexB);
              });
      }, (_) {});
      _isLoading = false;
    });

    if (_selectedCategoryId != null) {
      // Resolve the real CategoryEntity for a pre-selected id (e.g. editing
      // a transaction) so the caller gets full entity data, not just an id.
      // Look this up against the *unfiltered* category list, not the
      // enabled-only [_categories]: a transaction may have been recorded
      // with a category that was since disabled, and editing it must still
      // report that category back to the caller — otherwise the caller's
      // selected category stays null and Save is permanently blocked.
      CategoryEntity? preselected;
      for (final c in allCategories) {
        if (c.id == _selectedCategoryId) {
          preselected = c;
          break;
        }
      }
      if (preselected != null) {
        widget.onCategorySelected?.call(preselected);
        return;
      }
    }

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
        const CcSpaceXS(),
        if (_isLoading)
          _buildShimmerList(context)
        else
          _buildCategoryList(context),
      ],
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return SizedBox(
      height: context.respDim(90),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        itemCount: 5,
        separatorBuilder: (context, index) => const CcSpaceSM(),
        itemBuilder: (context, index) => Container(
          width: context.respDim(68),
          padding: EdgeInsets.all(context.respDim(10)),
          decoration: BoxDecoration(
            color: context.ccColorScheme.onSurface.withAlpha(10),
            borderRadius: context.brLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CcShimmer(
                width: context.respDim(35),
                height: context.respDim(35),
                borderRadius: context.brMd,
              ),
              const CcSpaceXS(),
              CcShimmer(
                width: context.respDim(40),
                height: context.respDim(10),
                borderRadius: context.brXs,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: CcText(
        widget.title ?? el.tr(CcLocaleKeys.transaction_category),
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
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

    return CcInkWell(
      onTap: () {
        setState(() => _selectedCategoryId = category.id);
        widget.onCategorySelected?.call(category);
      },
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: widget.activeColor.withAlpha(30),
                endColor: widget.activeColor.withAlpha(50),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(68),
            padding: EdgeInsets.all(context.respDim(10)),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.activeColor.withAlpha(10)
                  : scheme.onSurface.withAlpha(10),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? widget.activeColor.withAlpha(20)
                    : scheme.onSurface.withAlpha(10),
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
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: isSelected
            ? widget.activeColor.withAlpha(20)
            : scheme.onSurface.withAlpha(10),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: widget.activeColor.withAlpha(30),
                endColor: widget.activeColor.withAlpha(50),
              ),
            ),
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
