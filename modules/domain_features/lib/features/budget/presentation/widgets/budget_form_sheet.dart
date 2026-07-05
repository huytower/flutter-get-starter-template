import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
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

  bool get _isReset => widget.resetTarget != null;

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
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;
    result.when((categories) {
      setState(() {
        _categories = categories;
        _selectedCategoryId ??=
            categories.isNotEmpty ? categories.first.id : null;
      });
    }, (_) {});
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
    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: _isReset
          ? el.tr(CcLocaleKeys.budget_period_started)
          : el.tr(CcLocaleKeys.budget_added),
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
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: el.tr(CcLocaleKeys.budget_category),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _categories
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(el.tr(c.nameKey)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedCategoryId = value),
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
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.ccColorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: CcText(
                el.tr(CcLocaleKeys.common_save),
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
