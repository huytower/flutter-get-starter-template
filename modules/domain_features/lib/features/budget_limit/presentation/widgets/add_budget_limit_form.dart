import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../../domain/usecases/create_budget_limit_usecase.dart';
import '../../domain/usecases/get_category_average_monthly_spend_usecase.dart';
import '../../domain/usecases/update_budget_limit_usecase.dart';
import '../get_x/budget_limit_controller.dart';
import 'budget_limit_category_selector.dart';
import 'budget_limit_lock_notice.dart';
import 'budget_limit_name_input.dart';

/// Bottom sheet to create a budget, or edit an existing one when
/// [editTarget] is provided. The category is fixed after creation; the name
/// can change any time, the limit only during days 1–7 of the month (the
/// limit input is hidden outside that window).
class AddBudgetLimitForm extends StatefulWidget {
  final BudgetLimitEntity? editTarget;

  const AddBudgetLimitForm({super.key, this.editTarget});

  @override
  State<AddBudgetLimitForm> createState() => _AddBudgetLimitFormState();
}

class _AddBudgetLimitFormState extends State<AddBudgetLimitForm> {
  final _controller = Get.isRegistered<BudgetLimitController>()
      ? Get.find<BudgetLimitController>()
      : Get.put(getIt<BudgetLimitController>());
  final _nameController = TextEditingController();
  final _amountFieldKey = GlobalKey();

  String _limitStr = '0';
  String? _nameError;
  bool _showKeypad = false;

  List<CategoryEntity> _categories = const [];
  String? _selectedCategoryId;
  ScrollController? _categoryScrollController;
  bool _isFixedPrice = false;

  /// Phase 3.4 "Smart Budget Setup" estimate — average of the selected
  /// category's last 3 months of actual spend, offered as a tappable
  /// suggestion for the limit. Null hides the suggestion (no history, or
  /// already applied/dismissed).
  int? _estimatedLimit;

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
      _isFixedPrice = target.isFixedPrice;
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
      // Create index map to preserve seed order
      final seedIndexMap = <String, int>{};
      for (int i = 0; i < CategorySeed.categories.length; i++) {
        seedIndexMap[CategorySeed.categories[i].id] = i;
      }

      // Budgets only cap expenses.
      final enabled =
          categories
              .where((c) => c.isEnabled && c.type == CategoryType.expense)
              .toList()
            ..sort((a, b) {
              final indexA = seedIndexMap[a.id] ?? 999;
              final indexB = seedIndexMap[b.id] ?? 999;
              return indexA.compareTo(indexB);
            });
      setState(() {
        _categories = enabled;
        if (_selectedCategoryId == null && enabled.isNotEmpty) {
          _selectedCategoryId = enabled.first.id;
          _nameController.text = el.tr(enabled.first.nameKey);
        }
      });
      _scrollToSelectedCategory(enabled);
      if (_selectedCategoryId != null) _loadEstimate(_selectedCategoryId!);
    }, (_) {});
  }

  Future<void> _loadEstimate(String categoryId) async {
    final result = await getIt<GetCategoryAverageMonthlySpendUseCase>().call(
      categoryId,
    );
    if (!mounted) return;
    final estimate = result.tryGetSuccess() ?? 0;
    setState(() => _estimatedLimit = estimate > 0 ? estimate : null);
  }

  void _applyEstimate() {
    setState(() {
      _limitStr = _estimatedLimit.toString();
      _estimatedLimit = null;
    });
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
            isFixedPrice: _isFixedPrice,
          )
        : await _controller.createBudget(
            CreateBudgetLimitParams(
              categoryId: _selectedCategoryId ?? '',
              name: _nameController.text,
              limit: limit,
              isFixedPrice: _isFixedPrice,
            ),
          );

    if (!mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
      return;
    }

    // Guideline tasks
    if (!_isEdit) {
      Get.find<GuidelineController>().completeTask('budget_limit');
      if (_isFixedPrice) {
        Get.find<GuidelineController>().completeTask('min_living');
      }
    }

    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: _isEdit
          ? el.tr(CcLocaleKeys.budget_updated, namedArgs: {'name': budgetName})
          : el.tr(CcLocaleKeys.budget_added, namedArgs: {'name': budgetName}),
    );
    Navigator.pop(context);
  }

  Widget _buildFixedPriceHeaderToggle(BuildContext context) {
    final scheme = context.ccColorScheme;
    final guideline = Get.find<GuidelineController>();

    return CcInkWell(
      onTap: () => setState(() => _isFixedPrice = !_isFixedPrice),
      borderRadius: context.brSm,
      child: Tooltip(
        message: el.tr(CcLocaleKeys.budget_fixed_price),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respDim(8),
            vertical: context.respDim(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CcIconToken(
                      Icons.bolt_rounded,
                      size: 18,
                      color: _isFixedPrice ? scheme.primary : scheme.outline,
                    ),
                    if (guideline.isTaskActive('min_living'))
                      Positioned(
                        top: -6,
                        right: -6,
                        child: CcGuidelineBadge(
                          size: 4,
                          color: guideline.currentColor,
                          bounceTrigger: guideline.bounceTrigger,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: context.respDim(30),
                height: context.respDim(30),
                child: Checkbox(
                  value: _isFixedPrice,
                  onChanged: (v) => setState(() => _isFixedPrice = v ?? false),
                  activeColor: scheme.primary,
                  side: BorderSide(color: scheme.outline, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: context.brXs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstimateSuggestion(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcInkWell(
        onTap: _applyEstimate,
        borderRadius: context.brMd,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.respDim(10),
            vertical: context.respDim(8),
          ),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.08),
            borderRadius: context.brMd,
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: context.respIconSize(baseSize: 16),
                color: scheme.primary,
              ),
              const CcSpaceXS(),
              Expanded(
                child: CcText(
                  el.tr(
                    CcLocaleKeys.budget_estimate_hint,
                    namedArgs: {
                      'amount': formatVndWithSymbol(_estimatedLimit ?? 0),
                    },
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CcInkWell(
                onTap: () => setState(() => _estimatedLimit = null),
                borderRadius: context.brSm,
                child: Icon(
                  Icons.close,
                  size: context.respIconSize(baseSize: 16),
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CcText(
                      _isEdit
                          ? el.tr(CcLocaleKeys.budget_edit_title)
                          : el.tr(CcLocaleKeys.budget_add_title),
                      textStyle: context.ccTextTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.ccColorScheme.primary,
                      ),
                    ),
                    _buildFixedPriceHeaderToggle(context),
                  ],
                ),
                const CcSpaceXS(),
                BudgetLimitNameInput(
                  controller: _nameController,
                  errorText: _nameError,
                  onClear: () => _nameController.clear(),
                  onTap: () {
                    if (_showKeypad) setState(() => _showKeypad = false);
                  },
                ),
                const CcSpaceXS(),
                if (!_isEdit) ...[
                  BudgetLimitCategorySelector(
                    categories: _categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (cat) {
                      setState(() {
                        _selectedCategoryId = cat.id;
                        _nameController.text = el.tr(cat.nameKey);
                        _estimatedLimit = null;
                        if (_showKeypad) _showKeypad = false;
                      });
                      FocusScope.of(context).unfocus();
                      _loadEstimate(cat.id);
                    },
                    onScrollControllerCreated: (controller) =>
                        _categoryScrollController = controller,
                  ),
                ],
                const CcSpaceXS(),
                if (!_isEdit && _estimatedLimit != null) ...[
                  _buildEstimateSuggestion(context),
                ],
                if (_limitLocked)
                  const BudgetLimitLockNotice()
                else
                  CcAmountInputSection(
                    label: el.tr(CcLocaleKeys.budget_limit),
                    amountStr: _limitStr,
                    quickAmounts: MoneyConstants.budgetQuickAmounts,
                    isKeypadVisible: _showKeypad,
                    fieldKey: _amountFieldKey,
                    onTap: () {
                      setState(() => _showKeypad = true);
                      FocusScope.of(context).unfocus();
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
                    onClear: () => setState(() => _limitStr = '0'),
                    onCopy: () => CcStringHelper.copyToClipboard(_limitStr),
                  ),
                const CcSpaceSM(),
                CcSaveButton(
                  onPressed: _isValid ? _onSave : null,
                  label: el.tr(CcLocaleKeys.common_save),
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
            suggestions: MoneyConstants.budgetQuickAmounts,
            onSuggestion: (value) =>
                setState(() => _limitStr = value.toString()),
            onDone: () => setState(() => _showKeypad = false),
            activeColor: context.ccColorScheme.primary,
          ),
      ],
    );
  }
}
