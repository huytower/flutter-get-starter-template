import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/usecases/create_budget_usecase.dart';
import '../get_x/budget_controller.dart';

/// Bottom sheet to create a budget, or open a new period for an existing one
/// when [resetTarget] is provided.
class BudgetFormSheet extends StatefulWidget {
  final BudgetEntity? resetTarget;

  const BudgetFormSheet({super.key, this.resetTarget});

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final _controller = Get.find<BudgetController>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();

  List<CategoryEntity> _categories = const [];
  String? _selectedCategoryId;
  late DateTime _startDate;
  late DateTime _endDate;
  ScrollController? _categoryScrollController;

  bool get _isReset => widget.resetTarget != null;

  bool get _isValid {
    final name = _nameController.text.trim();
    final limit = int.tryParse(_limitController.text.trim()) ?? 0;
    return name.isNotEmpty &&
        _selectedCategoryId != null &&
        limit > 0 &&
        !_endDate.isBefore(_startDate);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 7));

    final target = widget.resetTarget;
    if (target != null) {
      _nameController.text = target.name;
      _selectedCategoryId = target.categoryId;
      _limitController.text = target.limit.toString();
    }
    _nameController.addListener(() => setState(() {}));
    _limitController.addListener(() => setState(() {}));
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;
    result.when((categories) {
      final enabled = categories.where((c) => c.isEnabled).toList();
      setState(() {
        _categories = enabled;
        _selectedCategoryId ??= enabled.isNotEmpty ? enabled.first.id : null;
      });
      _scrollToSelectedCategory(enabled);
    }, (_) {});
  }

  void _scrollToSelectedCategory(List<CategoryEntity> categories) {
    if (_selectedCategoryId == null) return;
    final index = categories.indexWhere((c) => c.id == _selectedCategoryId);
    if (index <= 0) return;
    // item width (68) + separator (8) = 76 per slot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _categoryScrollController?.animateTo(
        index * 76.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _onSave() async {
    final params = CreateBudgetParams(
      categoryId: _selectedCategoryId ?? '',
      name: _nameController.text,
      limit: int.tryParse(_limitController.text.trim()) ?? 0,
      startDate: _startDate,
      endDate: _endDate,
    );

    final error = _isReset
        ? await _controller.resetBudget(widget.resetTarget!.id, params)
        : await _controller.createBudget(params);

    if (!mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
      return;
    }
    Navigator.pop(context);
    final budgetName = _nameController.text.trim();
    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: _isReset
          ? el.tr(CcLocaleKeys.budget_updated, namedArgs: {'name': budgetName})
          : el.tr(CcLocaleKeys.budget_added, namedArgs: {'name': budgetName}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.respPadding(CcPaddingParams.SPACE_LG),
        right: context.respPadding(CcPaddingParams.SPACE_LG),
        top: context.respPadding(CcPaddingParams.SPACE_LG),
        bottom: MediaQuery.of(context).viewInsets.bottom +
            context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            _isReset
                ? el.tr(CcLocaleKeys.budget_reset_title)
                : el.tr(CcLocaleKeys.budget_add_title),
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.ccColorScheme.primary,
            ),
          ),
          const CcSpaceMD(),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: el.tr(CcLocaleKeys.budget_name),
              hintText: el.tr(CcLocaleKeys.budget_name_hint),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const CcSpaceMD(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CcText(
                el.tr(CcLocaleKeys.budget_category),
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: context.respFontSize(12),
                ),
              ),
              const CcSpaceSM(),
              HorizontalFadeScrollView(
                height: context.respDim(80),
                builder: (scrollController) {
                  _categoryScrollController = scrollController;
                  return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const CcSpaceSM(),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategoryId == cat.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: SizedBox(
                        width: context.respDim(68),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: context.respDim(52),
                              height: context.respDim(52),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.ccColorScheme.primary
                                    : const Color(0xFFF1F3F5),
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
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            const CcSpaceXS(),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              style: (context.ccTextTheme.bodySmall ??
                                      const TextStyle())
                                  .copyWith(
                                fontSize: context.respFontSize(9),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? context.ccColorScheme.primary
                                    : Colors.grey[700],
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
          ),
          const CcSpaceMD(),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: el.tr(CcLocaleKeys.budget_limit),
              hintText: el.tr(CcLocaleKeys.budget_limit_hint),
              suffixText: 'đ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const CcSpaceMD(),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: el.tr(CcLocaleKeys.budget_start_date),
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const CcSpaceMD(),
              Expanded(
                child: _DateField(
                  label: el.tr(CcLocaleKeys.budget_end_date),
                  date: _endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const CcSpaceLG(),
          SizedBox(
            width: double.infinity,
            height: context.respDim(50),
            child: ElevatedButton(
              onPressed: _isValid ? _onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.ccColorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: CcText(
                el.tr(CcLocaleKeys.common_save),
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: CcText(
          '${date.day}/${date.month}/${date.year}',
          textStyle: context.ccTextTheme.bodyMedium,
        ),
      ),
    );
  }
}
