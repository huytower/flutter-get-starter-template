import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../../domain/usecases/create_budget_limit_usecase.dart';
import '../../domain/usecases/update_budget_limit_usecase.dart';
import '../get_x/budget_limit_controller.dart';

/// Bottom sheet to create a budget, or edit an existing one when
/// [editTarget] is provided. The category is fixed after creation; the name
/// can change any time, the limit only during days 1–7 of the month (the
/// limit input is hidden outside that window).
class BudgetLimitFormSheet extends StatefulWidget {
  final BudgetLimitEntity? editTarget;

  const BudgetLimitFormSheet({super.key, this.editTarget});

  @override
  State<BudgetLimitFormSheet> createState() => _BudgetLimitFormSheetState();
}

class _BudgetLimitFormSheetState extends State<BudgetLimitFormSheet> {
  final _controller = Get.isRegistered<BudgetLimitController>()
      ? Get.find<BudgetLimitController>()
      : Get.put(getIt<BudgetLimitController>(), permanent: true);
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();

  List<CategoryEntity> _categories = const [];
  String? _selectedCategoryId;
  ScrollController? _categoryScrollController;

  bool get _isEdit => widget.editTarget != null;

  /// Limits may only change during the first week of the month (days 1–7).
  bool get _limitLocked => _isEdit && !UpdateBudgetLimitUseCase.isLimitEditable;

  bool get _isValid {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedCategoryId == null) return false;
    // While the limit is locked its input is hidden, so only the name has
    // to be valid.
    if (_limitLocked) return true;
    final limit = int.tryParse(_limitController.text.trim()) ?? 0;
    return limit > 0;
  }

  @override
  void initState() {
    super.initState();
    final target = widget.editTarget;
    if (target != null) {
      _nameController.text = target.name;
      _selectedCategoryId = target.categoryId;
      _limitController.text = target.limit.toString();
    }
    _nameController.addListener(() => setState(() {}));
    _limitController.addListener(() => setState(() {}));
    if (!_isEdit) _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;
    result.when((categories) {
      // Budgets only cap expenses.
      final enabled = categories
          .where((c) => c.isEnabled && c.type == CategoryType.expense)
          .toList();
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

  Future<void> _onSave() async {
    final limit = int.tryParse(_limitController.text.trim()) ?? 0;

    final error = _isEdit
        ? await _controller.updateBudget(
            widget.editTarget!.id,
            name: _nameController.text,
            limit: _limitLocked ? null : limit,
          )
        : await _controller.createBudget(
            CreateBudgetLimitParams(
              categoryId: _selectedCategoryId ?? '',
              name: _nameController.text,
              limit: limit,
            ),
          );

    if (!mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
      return;
    }
    final budgetName = _nameController.text.trim();
    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: _isEdit
          ? el.tr(CcLocaleKeys.budget_updated, namedArgs: {'name': budgetName})
          : el.tr(CcLocaleKeys.budget_added, namedArgs: {'name': budgetName}),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.respPadding(CcPaddingParams.SPACE_LG),
        right: context.respPadding(CcPaddingParams.SPACE_LG),
        top: context.respPadding(CcPaddingParams.SPACE_LG),
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            _isEdit
                ? el.tr(CcLocaleKeys.budget_edit_title)
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (!_isEdit) ...[
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
                  height: context.respDim(90),
                  builder: (scrollController) {
                    _categoryScrollController = scrollController;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const CcSpaceSM(),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: _isEdit
                              ? null
                              : () => setState(
                                  () => _selectedCategoryId = cat.id,
                                ),
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
          ], // end if (!_isEdit)
          const CcSpaceMD(),
          if (_limitLocked)
            Row(
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  size: context.respIconSize(baseSize: 16),
                  color: Colors.grey[600],
                ),
                const CcSpaceSM(),
                Expanded(
                  child: CcText(
                    el.tr(CcLocaleKeys.budget_limit_locked),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            )
          else
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: el.tr(CcLocaleKeys.budget_limit),
                hintText: el.tr(CcLocaleKeys.budget_limit_hint),
                suffixText: 'đ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
