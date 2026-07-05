import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/icon_utils.dart';

class CategorySelectionSection extends StatefulWidget {
  final Function(CategoryEntity)? onCategorySelected;
  final Color activeColor;

  const CategorySelectionSection({
    super.key,
    this.onCategorySelected,
    this.activeColor = const Color(0xFF13C07F),
  });

  @override
  State<CategorySelectionSection> createState() =>
      _CategorySelectionSectionState();
}

class _CategorySelectionSectionState extends State<CategorySelectionSection> {
  List<CategoryGroupEntity> _groups = const [];
  List<CategoryEntity> _allCategories = const [];

  String? _selectedGroupId;
  String? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final groupsResult = await getIt<GetCategoryGroupsUseCase>().call();
    final categoriesResult = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;

    setState(() {
      groupsResult.when((groups) => _groups = groups, (_) {});
      categoriesResult.when(
        (categories) => _allCategories = categories,
        (_) {},
      );
      _selectedGroupId = _groups.isNotEmpty ? _groups.first.id : null;
      _isLoading = false;
    });
  }

  List<CategoryEntity> get _filteredCategories =>
      _allCategories.where((cat) => cat.groupId == _selectedGroupId).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
          ),
          child: Row(
            children: [
              CcIcon(
                icon: Icons.local_offer,
                size: context.respIconSize(baseSize: 16),
                color: widget.activeColor,
              ),
              const CcSpaceSM(),
              CcText(
                el.tr(CcLocaleKeys.transaction_category),
                textStyle: context.ccTextTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: context.respFontSize(13),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const CcSpaceSM(),
        if (_isLoading)
          SizedBox(
            height: context.respDim(100),
            child: const Center(child: CircularProgressIndicator()),
          )
        else ...[
          _buildGroupChips(context),
          const CcSpaceMD(),
          _buildCategoryList(context),
        ],
      ],
    );
  }

  Widget _buildGroupChips(BuildContext context) {
    // Fade the right edge of the group labels to hint there's more to scroll.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFFFFFFFF), Color(0x26FFFFFF)],
        stops: [0.65, 1.0],
      ).createShader(bounds),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        child: Row(
          children: _groups.map((group) {
            final isSelected = _selectedGroupId == group.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: CcText(
                  el.tr(group.nameKey),
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: context.respFontSize(12),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedGroupId = group.id);
                },
                selectedColor: widget.activeColor,
                backgroundColor: const Color(0xFFF1F3F5),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: context.respDim(68),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        itemCount: _filteredCategories.length,
        separatorBuilder: (context, index) => const CcSpaceSM(),
        itemBuilder: (context, index) {
          final category = _filteredCategories[index];
          final isSelected = _selectedCategoryId == category.id;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryId = category.id);
              widget.onCategorySelected?.call(category);
            },
            child: Container(
              width: context.respDim(68),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.activeColor.withValues(alpha: 0.1)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: widget.activeColor, width: 1.5)
                    : null,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: widget.activeColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CcIcon(
                    icon: iconDataFromCode(
                      category.iconCode,
                      fontFamily: category.iconFamily,
                    ),
                    size: context.respIconSize(baseSize: 22),
                    color: isSelected ? widget.activeColor : Colors.grey[600],
                  ),
                  const CcSpaceXS(),
                  CcText(
                    el.tr(category.nameKey),
                    align: Alignment.center,
                    textAlign: TextAlign.center,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      fontSize: context.respFontSize(9),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? widget.activeColor : Colors.grey[800],
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
