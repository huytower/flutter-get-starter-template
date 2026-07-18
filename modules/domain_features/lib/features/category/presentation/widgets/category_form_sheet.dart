import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import 'category_icon_selector.dart';

class CategoryFormSheet extends StatefulWidget {
  final CategoryEntity? target;
  final String? defaultGroupId;
  final String type;
  final String title;
  final List<IconData> iconPresets;

  const CategoryFormSheet({
    super.key,
    this.target,
    this.defaultGroupId,
    required this.type,
    required this.title,
    required this.iconPresets,
  });

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  late final TextEditingController _nameController;
  late int _iconCode;
  bool _isSaving = false;
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
    _iconCode = widget.target?.iconCode ?? widget.iconPresets.first.codePoint;
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
              groupId: widget.defaultGroupId ?? '',
              type: widget.type,
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
            widget.title,
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary
            ),
          ),
          const CcSpaceMD(),
          TextField(
            controller: _nameController,
            style: context.ccTextTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: el.tr(CcLocaleKeys.transaction_category),
              hintText: el.tr(CcLocaleKeys.wallet_name_hint),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.respDim(12)),
              ),
            ),
          ),
          const CcSpaceMD(),
          CategoryIconSelector(
            icons: widget.iconPresets,
            selectedIconCode: _iconCode,
            onIconSelected: (code) => setState(() => _iconCode = code),
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
                  borderRadius: BorderRadius.circular(context.respDim(12)),
                ),
              ),
              child: _isSaving
                  ? const CcLoadingIconWidget()
                  : CcText(
                      el.tr(CcLocaleKeys.common_save),
                      align: Alignment.center,
                      textAlign: TextAlign.center,
                      textStyle: context.ccTextTheme.labelLarge?.copyWith(
                        color: scheme.onPrimary,
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
