import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
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
      : Get.put(getIt<BudgetLimitController>());
  final _nameController = TextEditingController();
  final _amountFieldKey = GlobalKey();

  String _limitStr = '0';
  String? _nameError;
  bool _showKeypad = false;

  static const List<int> _quickAmounts = [
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
    10000000,
  ];

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
    final limit = int.tryParse(_limitStr.trim()) ?? 0;
    return limit > 0;
  }

  @override
  void initState() {
    super.initState();
    final target = widget.editTarget;
    if (target != null) {
      _nameController.text = target.name;
      _selectedCategoryId = target.categoryId;
      _limitStr = target.limit.toString();
    }
    _nameController.addListener(() {
      if (_nameError != null) setState(() => _nameError = null);
      setState(() {});
    });
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
        if (_selectedCategoryId == null && enabled.isNotEmpty) {
          _selectedCategoryId = enabled.first.id;
          _nameController.text = el.tr(enabled.first.nameKey);
        }
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
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (_limitStr == '0') {
        if (key != '0' && key != '000') _limitStr = key;
      } else {
        _limitStr += key;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_limitStr.length > 1) {
        _limitStr = _limitStr.substring(0, _limitStr.length - 1);
      } else {
        _limitStr = '0';
      }
    });
  }

  Future<void> _onSave() async {
    final budgetName = _nameController.text.trim();
    final isDuplicate = _controller.budgets.any((b) {
      if (_isEdit && b.budget.id == widget.editTarget!.id) return false;
      return b.budget.name.trim().toLowerCase() == budgetName.toLowerCase();
    });

    if (isDuplicate) {
      setState(
        () => _nameError = el.tr(CcLocaleKeys.budget_name_duplicate_error),
      );
      return;
    }

    final limit = int.tryParse(_limitStr.trim()) ?? 0;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_showKeypad) setState(() => _showKeypad = false);
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: context.respPadding(CcPaddingParams.SPACE_LG),
              right: context.respPadding(CcPaddingParams.SPACE_LG),
              top: context.respPadding(CcPaddingParams.SPACE_LG),
              bottom:
                  (_showKeypad ? 0 : MediaQuery.of(context).viewInsets.bottom) +
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
                    errorText: _nameError,
                    suffixIcon: _nameController.text.isNotEmpty
                        ? CcIconButton.bouncing(
                            icon: const Icon(Icons.clear, size: 20),
                            onTap: () => _nameController.clear(),
                          )
                        : null,
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
                          color: context.ccColorScheme.onSurfaceVariant,
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
                                    : () {
                                        setState(() {
                                          _selectedCategoryId = cat.id;
                                          _nameController.text = el.tr(
                                            cat.nameKey,
                                          );
                                        });
                                      },
                                child: SizedBox(
                                  width: context.respDim(68),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeInOut,
                                        width: context.respDim(52),
                                        height: context.respDim(52),
                                        decoration: BoxDecoration(
                                           color: isSelected
                                               ? context.ccColorScheme.primary
                                               : context.ccColorScheme.surfaceVariant,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Center(
                                          child: CcIcon(
                                            icon: iconDataFromCode(
                                              cat.iconCode,
                                              fontFamily: cat.iconFamily,
                                            ),
                                            size: context.respIconSize(
                                              baseSize: 22,
                                            ),
                                            color: isSelected
                                                ? context.ccColorScheme.onPrimary
                                                : context.ccColorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      const CcSpaceXS(),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeInOut,
                                        style:
                                            (context.ccTextTheme.bodySmall ??
                                                    const TextStyle())
                                                .copyWith(
                                                  fontSize: context
                                                      .respFontSize(9),
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? context
                                                            .ccColorScheme
                                                            .primary
                                                      : context.ccColorScheme.onSurfaceVariant,
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
                        color: context.ccColorScheme.onSurfaceVariant,
                      ),
                      const CcSpaceSM(),
                      Expanded(
                        child: CcText(
                          el.tr(CcLocaleKeys.budget_limit_locked),
                          textStyle: context.ccTextTheme.bodySmall?.copyWith(
                            color: context.ccColorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  CcAmountInputSection(
                    label: el.tr(CcLocaleKeys.budget_limit),
                    amountStr: _limitStr,
                    quickAmounts: _quickAmounts,
                    isKeypadVisible: _showKeypad,
                    fieldKey: _amountFieldKey,
                    onTap: () {
                      setState(() => _showKeypad = true);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final ctx = _amountFieldKey.currentContext;
                        if (ctx != null) {
                          Scrollable.ensureVisible(
                            ctx,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    },
                    onQuickAmountSelected: (amount) =>
                        setState(() => _limitStr = amount.toString()),
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
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: context.ccColorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showKeypad)
          MoneyKeypadPanel(
            onKeyPress: _onKeyPress,
            onDelete: _onDelete,
            onClear: () => setState(() => _limitStr = '0'),
            suggestions: _quickAmounts,
            onSuggestion: (value) =>
                setState(() => _limitStr = value.toString()),
            onDone: () => setState(() => _showKeypad = false),
            activeColor: context.ccColorScheme.primary,
          ),
      ],
    );
  }
}
