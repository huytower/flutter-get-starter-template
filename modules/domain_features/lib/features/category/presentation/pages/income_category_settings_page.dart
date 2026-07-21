import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../data/datasources/local/category_seed.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../util/category_ui_utils.dart';
import '../widgets/category_form_sheet.dart';
import '../widgets/category_list_tile.dart';

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

  static final List<IconData> _incomeIconPresets = [
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.respDim(16)),
        ),
      ),
      builder: (_) => CategoryFormSheet(
        target: target,
        type: CategoryType.income,
        defaultGroupId: CategorySeed.incomeGroupId,
        title: el.tr(
          target != null
              ? CcLocaleKeys.common_edit
              : CcLocaleKeys.common_next, // Placeholder for Add
        ),
        iconPresets: _incomeIconPresets,
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _confirmDelete(CategoryEntity category) async {
    final confirmed = await CategoryUiUtils.showDeleteConfirmation(
      context: context,
      category: category,
      title:
          "${el.tr(CcLocaleKeys.common_delete)} ${el.tr(CcLocaleKeys.category_income_settings_title).toLowerCase()}",
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
            el.tr(CcLocaleKeys.category_income_settings_title),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
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
                el.tr(CcLocaleKeys.common_no_data),
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
                return CategoryListTile(
                  category: category,
                  onTap: () => _openForm(target: category),
                  onDelete: () => _confirmDelete(category),
                );
              },
            ),
    );
  }
}
