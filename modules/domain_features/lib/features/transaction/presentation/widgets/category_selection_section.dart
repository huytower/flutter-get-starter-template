import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

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
  String _selectedGroupId = '1';
  String? _selectedCategoryId;

  final List<Map<String, dynamic>> _groups = [
    {'id': '1', 'name': 'Ăn uống & Cà phê'},
    {'id': '2', 'name': 'Di chuyển'},
    {'id': '3', 'name': 'Tiện ích'},
    {'id': '4', 'name': 'Nhà cửa'},
  ];

  final List<CategoryEntity> _allCategories = [
    // Nhóm 1: Ăn uống (ID '1')
    CategoryEntity(
      id: 'c1',
      nameKey: CcLocaleKeys.category_food_drink,
      iconCode: 0xe25a,
      groupId: '1',
    ),
    CategoryEntity(
      id: 'c2',
      nameKey: CcLocaleKeys.category_coffee,
      iconCode: 0xe0af,
      groupId: '1',
    ),
    CategoryEntity(
      id: 'c3',
      nameKey: CcLocaleKeys.category_water,
      iconCode: 0xe41b,
      groupId: '1',
    ),
    CategoryEntity(
      id: 'c4',
      nameKey: CcLocaleKeys.category_eat_out,
      iconCode: 0xe56c,
      groupId: '1',
    ),

    // Nhóm 2: Di chuyển (ID '2')
    CategoryEntity(
      id: 'c5',
      nameKey: CcLocaleKeys.category_taxi,
      iconCode: 0xe404,
      groupId: '2',
    ),
    CategoryEntity(
      id: 'c6',
      nameKey: CcLocaleKeys.category_gas,
      iconCode: 0xe3ab,
      groupId: '2',
    ),
    CategoryEntity(
      id: 'c7',
      nameKey: CcLocaleKeys.category_parking,
      iconCode: 0xe44d,
      groupId: '2',
    ),
    CategoryEntity(
      id: 'c8',
      nameKey: CcLocaleKeys.category_maintenance,
      iconCode: 0xe1bc,
      groupId: '2',
    ),

    // Nhóm 3: Tiện ích (ID '3')
    CategoryEntity(
      id: 'c9',
      nameKey: CcLocaleKeys.category_electricity,
      iconCode: 0xe230,
      groupId: '3',
    ),
    CategoryEntity(
      id: 'c10',
      nameKey: CcLocaleKeys.category_internet,
      iconCode: 0xe6e1,
      groupId: '3',
    ),
    CategoryEntity(
      id: 'c11',
      nameKey: CcLocaleKeys.category_phone,
      iconCode: 0xe53f,
      groupId: '3',
    ),

    // Nhóm 4: Nhà cửa (ID '4')
    CategoryEntity(
      id: 'c12',
      nameKey: CcLocaleKeys.category_rent,
      iconCode: 0xe318,
      groupId: '4',
    ),
    CategoryEntity(
      id: 'c13',
      nameKey: CcLocaleKeys.category_furniture,
      iconCode: 0xe1ad,
      groupId: '4',
    ),
    CategoryEntity(
      id: 'c14',
      nameKey: CcLocaleKeys.category_laundry,
      iconCode: 0xe3a8,
      groupId: '4',
    ),
  ];

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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
          ),
          child: Row(
            children: _groups.map((group) {
              final isSelected = _selectedGroupId == group['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: CcText(
                    group['name'],
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
                    setState(() {
                      _selectedGroupId = group['id'];
                    });
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
        const CcSpaceMD(),
        SizedBox(
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
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                  widget.onCategorySelected?.call(category);
                },
                child: Container(
                  width: context.respDim(68),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.activeColor.withOpacity(0.1)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: widget.activeColor, width: 1.5)
                        : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: widget.activeColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CcIcon(
                        icon: IconData(
                          category.iconCode,
                          fontFamily: 'MaterialIcons',
                        ),
                        size: context.respIconSize(baseSize: 22),
                        color: isSelected
                            ? widget.activeColor
                            : Colors.grey[600],
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
                          color: isSelected
                              ? widget.activeColor
                              : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
