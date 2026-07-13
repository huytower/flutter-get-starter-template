import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../../../core/util/icon_utils.dart';
import '../../data/datasources/local/category_seed.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';

/// Full CRUD over income categories ("hạng mục thu nhập"), reached from the
/// Profile screen. The income entry form only reads what's configured here.
class IncomeCategorySettingsPage extends StatefulWidget {
  const IncomeCategorySettingsPage({super.key});

  @override
  State<IncomeCategorySettingsPage> createState() =>
      _IncomeCategorySettingsPageState();
}

class _IncomeCategorySettingsPageState
    extends State<IncomeCategorySettingsPage> {
  List<CategoryEntity> _categories = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;
    setState(() {
      result.when((categories) {
        _categories = categories
            .where((c) => c.type == CategoryType.income)
            .toList();
      }, (_) {});
      _isLoading = false;
    });
  }

  Future<void> _openForm({CategoryEntity? target}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _IncomeCategoryFormSheet(target: target),
    );
    if (saved == true) _load();
  }

  Future<void> _confirmDelete(CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa hạng mục thu nhập'),
        content: Text(
          'Xóa "${el.tr(category.nameKey)}"? Các giao dịch đã ghi vẫn giữ '
          'nguyên tên hạng mục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(el.tr(CcLocaleKeys.common_cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              el.tr(CcLocaleKeys.common_delete),
              style: TextStyle(color: context.ccColorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await getIt<DeleteCategoryUseCase>().call(category.id);
    if (!mounted) return;
    result.when(
      (_) => _load(),
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: error.message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ccColorScheme.surface,
      appBar: buildDomainGradientAppBar(
        context,
        leading: CcIconButton.bouncing(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: CcText(
            'Hạng mục thu nhập',
            textStyle: context.ccTextTheme.titleLarge?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.onPrimary,
            ),
          ),
        ),
      ),
      floatingActionButton: CcFloatingActionButton(
        iconData: Icons.add,
        onTap: () => _openForm(),
      ),
      body: _isLoading
          ? const Center(child: CcLoadingIconWidget())
          : _categories.isEmpty
          ? Center(
              child: CcText(
                'Chưa có hạng mục thu nhập nào.',
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.PAGE_SM),
              ),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _IncomeCategoryTile(
                  category: category,
                  onTap: () => _openForm(target: category),
                  onDelete: () => _confirmDelete(category),
                );
              },
            ),
    );
  }
}

class _IncomeCategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _IncomeCategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconDataFromCode(
              category.iconCode,
              fontFamily: category.iconFamily,
            ),
            size: 20,
            color: scheme.primary,
          ),
        ),
        title: CcText(
          el.tr(category.nameKey),
          textStyle: context.ccTextTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CcIconButton.bouncing(
          icon: Icon(Icons.delete_outline, color: scheme.error),
          onTap: onDelete,
        ),
      ),
    );
  }
}

/// Create/edit bottom sheet: name + icon preset grid.
class _IncomeCategoryFormSheet extends StatefulWidget {
  final CategoryEntity? target;

  const _IncomeCategoryFormSheet({this.target});

  @override
  State<_IncomeCategoryFormSheet> createState() =>
      _IncomeCategoryFormSheetState();
}

class _IncomeCategoryFormSheetState extends State<_IncomeCategoryFormSheet> {
  static final List<IconData> _iconPresets = [
    Icons.payments,
    Icons.card_giftcard,
    Icons.trending_up,
    Icons.redeem,
    Icons.work,
    Icons.storefront,
    Icons.savings,
    Icons.currency_exchange,
    Icons.home_work,
    Icons.more_horiz,
  ];

  late final TextEditingController _nameController;
  late int _iconCode;
  bool _isSaving = false;

  // Tracks what was shown in the name field on open so we can detect whether
  // the user actually changed the name. If unchanged, the original nameKey
  // (which may be a locale key for seed categories) is preserved on save.
  String _originalDisplayName = '';

  bool get _isEdit => widget.target != null;

  @override
  void initState() {
    super.initState();
    final displayName = widget.target != null
        ? el.tr(widget.target!.nameKey)
        : '';
    _originalDisplayName = displayName;
    _nameController = TextEditingController(text: displayName);
    _iconCode = widget.target?.iconCode ?? _iconPresets.first.codePoint;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSaving = true);

    // Preserve the original nameKey (possibly a locale key) when the display
    // name is unchanged; use the typed name only when the user actually edited it.
    final nameKey = (_isEdit && name == _originalDisplayName)
        ? widget.target!.nameKey
        : name;

    final result = _isEdit
        ? await getIt<UpdateCategoryUseCase>().call(
            widget.target!.copyWith(nameKey: nameKey, iconCode: _iconCode),
          )
        : await getIt<CreateCategoryUseCase>().call(
            CategoryEntity(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              nameKey: name,
              iconCode: _iconCode,
              groupId: CategorySeed.incomeGroupId,
              type: CategoryType.income,
            ),
          );

    if (!mounted) return;
    setState(() => _isSaving = false);
    result.when(
      (_) => Navigator.of(context).pop(true),
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: error.message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
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
            _isEdit ? 'Sửa hạng mục thu nhập' : 'Thêm hạng mục thu nhập',
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          const CcSpaceMD(),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên hạng mục',
              hintText: 'Ví dụ: Lương, Thưởng...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const CcSpaceMD(),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _iconPresets.map((icon) {
              final isSelected = _iconCode == icon.codePoint;
              return GestureDetector(
                onTap: () => setState(() => _iconCode = icon.codePoint),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary
                        : const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              );
            }).toList(),
          ),
          const CcSpaceLG(),
          SizedBox(
            width: double.infinity,
            height: context.respDim(50),
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty || _isSaving
                  ? null
                  : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
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
