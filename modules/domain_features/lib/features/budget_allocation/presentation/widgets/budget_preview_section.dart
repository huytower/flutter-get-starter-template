import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../budget_limit/domain/entities/budget_limit_stats_entity.dart';
import '../../../budget_limit/domain/usecases/sort_budget_limits_by_limit_usecase.dart';
import '../../../budget_limit/presentation/get_x/budget_limit_controller.dart';
import '../../../budget_limit/presentation/widgets/add_budget_limit_form_sheet.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';

/// Inline budget summary shown below the wallet strip on the Phân bổ tab.
///
/// Loads categories once on first build to resolve icons. The budget data comes
/// directly from the already-registered [BudgetLimitController].
class BudgetPreviewSection extends StatefulWidget {
  const BudgetPreviewSection({super.key});

  @override
  State<BudgetPreviewSection> createState() => _BudgetPreviewSectionState();
}

class _BudgetPreviewSectionState extends State<BudgetPreviewSection> {
  Map<String, CategoryEntity> _categoryMap = {};
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    result.when(
      (cats) {
        if (mounted) {
          setState(() {
            _categoryMap = {for (final c in cats) c.id: c};
            _categoriesLoaded = true;
          });
        }
      },
      (_) {
        if (mounted) setState(() => _categoriesLoaded = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_MD),
            context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(CcLocaleKeys.budget_this_month),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground,
                  fontSize: context.respFontSize(CcTypographyParams.titleSmall),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAddBudget(context),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      size: context.respIconSize(baseSize: 20),
                      color: scheme.primary,
                    ),
                  ),
                  SizedBox(width: context.respDim(8)),
                  GestureDetector(
                    onTap: () =>
                        context.router.push(const BudgetLimitManagementRoute()),
                    child: CcText(
                      el.tr(CcLocaleKeys.budget_see_all),
                      textStyle: context.ccTextTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: CcTypographyParams.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(() {
          // Overview shows only the 4 budgets with the highest limit.
          final budgets = getIt<SortBudgetLimitsByLimitUseCase>().call(
            Get.find<BudgetLimitController>().budgets,
            limit: 4,
          );
          if (budgets.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
                vertical: context.respDim(12),
              ),
              child: CcText(
                el.tr(CcLocaleKeys.budget_empty),
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            );
          }
          // 2-column grid — at most 4 cards, so no scrolling needed.
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
            ),
            child: Column(
              children: [
                for (var i = 0; i < budgets.length; i += 2) ...[
                  if (i > 0) SizedBox(height: context.respDim(10)),
                  Row(
                    children: [
                      Expanded(child: _buildCard(context, budgets[i])),
                      SizedBox(width: context.respDim(10)),
                      Expanded(
                        child: i + 1 < budgets.length
                            ? _buildCard(context, budgets[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
        SizedBox(height: context.respDim(24)),
      ],
    );
  }

  Widget _buildCard(BuildContext context, BudgetLimitStatsEntity stats) {
    return SizedBox(
      height: context.respDim(150),
      child: _BudgetPreviewCard(
        stats: stats,
        category: _categoryMap[stats.budget.categoryId],
      ),
    );
  }

  void _openAddBudget(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddBudgetLimitFormSheet(),
    );
  }
}

class _BudgetPreviewCard extends StatelessWidget {
  final BudgetLimitStatsEntity stats;
  final CategoryEntity? category;

  const _BudgetPreviewCard({required this.stats, this.category});

  static String _fmtShort(int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}tỷ đ';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}tr đ';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k đ';
    }
    return '$value đ';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final iconColor = category?.color ?? scheme.primary;
    // Cards are tinted per category; over-limit still overrides with red.
    final accent = stats.isOver ? scheme.error : iconColor;
    final pct = (stats.progress * 100).round();

    final iconCode = category?.iconCode;
    final iconFamily = category?.iconFamily;
    final iconData = iconCode != null
        ? iconDataFromCode(iconCode, fontFamily: iconFamily)
        : Icons.pie_chart_outline_rounded;

    return Container(
      padding: EdgeInsets.all(context.respDim(12)),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(context.respDim(16)),
      ),
      child: Column(
        // stretch so every child fills the full card width — makes textAlign work
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: context.respDim(48),
                  height: context.respDim(48),
                  child: CircularProgressIndicator(
                    value: stats.progress,
                    // Accent-tinted track so the ring reads in the category
                    // colour even at 0% spent.
                    backgroundColor: accent.withOpacity(0.25),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                    strokeWidth: 3.5,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(context.respDim(8)),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: context.respIconSize(baseSize: 16),
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.respDim(6)),
          CcText(
            stats.budget.name,
            align: Alignment.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
              fontSize: context.respFontSize(CcTypographyParams.labelMedium),
            ),
          ),
          CcText(
            el.tr(
              CcLocaleKeys.budget_percent_used,
              namedArgs: {'percent': '$pct'},
            ),
            align: Alignment.center,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: context.respFontSize(CcTypographyParams.labelSmall),
            ),
          ),
          CcText(
            stats.isOver
                ? el.tr(
                    CcLocaleKeys.budget_over_by,
                    namedArgs: {
                      'amount': _fmtShort(stats.spent - stats.budget.limit),
                    },
                  )
                : el.tr(
                    CcLocaleKeys.budget_remaining,
                    namedArgs: {'amount': _fmtShort(stats.remaining)},
                  ),
            align: Alignment.center,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: CcTypographyParams.bold,
              fontSize: context.respFontSize(CcTypographyParams.labelSmall),
            ),
          ),
        ],
      ),
    );
  }
}
