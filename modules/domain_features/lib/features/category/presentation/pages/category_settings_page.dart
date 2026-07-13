import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../../../core/util/icon_utils.dart';
import '../../data/datasources/local/category_seed.dart';

class CategorySettingsPage extends StatefulWidget {
  const CategorySettingsPage({super.key});

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  List<CategoryGroupEntity> _groups = const [];

  /// Expense categories, keyed by group id.
  Map<String, List<CategoryEntity>> _byGroup = const {};

  /// Income categories, keyed by income group id.
  Map<String, List<CategoryEntity>> _incomeByGroup = const {};

  /// Pending toggle state: categoryId → isEnabled.
  /// Only contains entries that differ from the persisted value.
  final Map<String, bool> _pending = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groupsResult = await getIt<GetCategoryGroupsUseCase>().call();
    final categoriesResult = await getIt<GetCategoriesUseCase>().call();
    if (!mounted) return;

    setState(() {
      groupsResult.when((groups) => _groups = groups, (_) {});
      categoriesResult.when((categories) {
        final byGroup = <String, List<CategoryEntity>>{};
        final incomeByGroup = <String, List<CategoryEntity>>{};
        for (final cat in categories) {
          if (cat.type == CategoryType.income) {
            incomeByGroup.putIfAbsent(cat.groupId, () => []).add(cat);
          } else {
            byGroup.putIfAbsent(cat.groupId, () => []).add(cat);
          }
        }
        _byGroup = byGroup;
        _incomeByGroup = incomeByGroup;
      }, (_) {});
      _isLoading = false;
    });
  }

  bool _isEnabled(CategoryEntity cat) =>
      _pending.containsKey(cat.id) ? _pending[cat.id]! : cat.isEnabled;

  bool get _hasAnyEnabled => [
    ..._byGroup.values.expand((c) => c),
    ..._incomeByGroup.values.expand((c) => c),
  ].any(_isEnabled);

  void _toggle(CategoryEntity cat) {
    setState(() {
      final current = _isEnabled(cat);
      _pending[cat.id] = !current;
    });
  }

  Future<void> _save() async {
    if (_pending.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSaving = true);
    final useCase = getIt<ToggleCategoryEnabledUseCase>();
    for (final entry in _pending.entries) {
      final result = await useCase.call(entry.key, entry.value);
      if (result.isError()) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: result.tryGetError()!.message,
        );
        return;
      }
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: el.tr(CcLocaleKeys.category_settings_saved),
    );
    // Small delay so the snackbar is visible before the page dismisses.
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.of(context).pop(true);
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
            el.tr(CcLocaleKeys.category_settings_title),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.onPrimary,
              fontSize: context.respFontSize(CcTypographyParams.titleMedium),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CcLoadingIconWidget())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                    vertical: context.respDim(8),
                  ),
                  child: CcText(
                    el.tr(CcLocaleKeys.category_settings_subtitle),
                    textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: context.respDim(100)),
                    // +2: one header for expense, one for income
                    itemCount:
                        1 +
                        _groups.length +
                        1 +
                        CategorySeed.incomeGroups.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: context.respDim(8),
                            left: context.respPadding(CcPaddingParams.PAGE_SM),
                            right: context.respPadding(CcPaddingParams.PAGE_SM),
                            bottom: context.respDim(4),
                          ),
                          child: CcText(
                            el.tr(CcLocaleKeys.category_expense_settings_title),
                            textStyle: context.ccTextTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.ccColorScheme.primary,
                                ),
                          ),
                        );
                      }
                      final expenseIndex = index - 1;
                      if (expenseIndex < _groups.length) {
                        final group = _groups[expenseIndex];
                        final cats = _byGroup[group.id] ?? [];
                        if (cats.isEmpty) return const SizedBox.shrink();
                        return _GroupSection(
                          group: group,
                          categories: cats,
                          isEnabled: _isEnabled,
                          onToggle: _toggle,
                        );
                      }
                      if (expenseIndex == _groups.length) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: context.respDim(24),
                            left: context.respPadding(CcPaddingParams.PAGE_SM),
                            right: context.respPadding(CcPaddingParams.PAGE_SM),
                            bottom: context.respDim(4),
                          ),
                          child: CcText(
                            el.tr(CcLocaleKeys.category_income_settings_title),
                            textStyle: context.ccTextTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                          ),
                        );
                      }
                      final incomeIndex = expenseIndex - _groups.length - 1;
                      final group = CategorySeed.incomeGroups[incomeIndex];
                      final cats = _incomeByGroup[group.id] ?? [];
                      if (cats.isEmpty) return const SizedBox.shrink();
                      return _GroupSection(
                        group: group,
                        categories: cats,
                        isEnabled: _isEnabled,
                        onToggle: _toggle,
                        accentColor: Colors.green.shade600,
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.respPadding(CcPaddingParams.PAGE_SM),
                  context.respDim(12),
                  context.respPadding(CcPaddingParams.PAGE_SM),
                  context.respDim(16),
                ),
                child: _isSaving
                    ? const Center(child: CcLoadingIconWidget())
                    : Builder(
                        builder: (context) {
                          final enabled = _hasAnyEnabled;
                          return CcBaseBtn(
                            onTap: enabled ? _save : null,
                            isEnable: enabled,
                            title: el.tr(CcLocaleKeys.category_settings_save),
                            bgColor: enabled
                                ? [
                                    context.ccColorScheme.primary,
                                    context.ccColorScheme.primary,
                                  ]
                                : null,
                          );
                        },
                      ),
              ),
            ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  final CategoryGroupEntity group;
  final List<CategoryEntity> categories;
  final bool Function(CategoryEntity) isEnabled;
  final void Function(CategoryEntity) onToggle;
  final Color? accentColor;

  const _GroupSection({
    required this.group,
    required this.categories,
    required this.isEnabled,
    required this.onToggle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.respDim(16),
        bottom: context.respDim(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
            ),
            child: CcText(
              el.tr(group.nameKey),
              textStyle: context.ccTextTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.ccColorScheme.onSurface,
              ),
            ),
          ),
          const CcSpaceSM(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
            ),
            child: Row(
              children: categories.map((cat) {
                final enabled = isEnabled(cat);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    category: cat,
                    enabled: enabled,
                    onTap: () => onToggle(cat),
                    accentColor: accentColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool enabled;
  final VoidCallback onTap;
  final Color? accentColor;

  const _CategoryChip({
    required this.category,
    required this.enabled,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = accentColor ?? context.ccColorScheme.primary;
    final chipBg = enabled
        ? primary.withOpacity(0.15)
        : context.ccColorScheme.surfaceContainerHighest;
    final iconColor = enabled
        ? primary
        : context.ccColorScheme.onSurfaceVariant;
    final textColor = enabled
        ? primary
        : context.ccColorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(context.respDim(24)),
          border: Border.all(
            color: enabled ? primary.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                enabled
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                key: ValueKey(enabled),
                size: context.respIconSize(baseSize: 16),
                color: iconColor,
              ),
            ),
            SizedBox(width: context.respDim(6)),
            Icon(
              iconDataFromCode(
                category.iconCode,
                fontFamily: category.iconFamily,
              ),
              size: context.respIconSize(baseSize: 14),
              color: iconColor,
            ),
            SizedBox(width: context.respDim(4)),
            CcText(
              el.tr(category.nameKey),
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: enabled ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
