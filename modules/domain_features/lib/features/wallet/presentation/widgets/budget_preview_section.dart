import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../budget/domain/entities/budget_stats_entity.dart';
import '../../../budget/presentation/get_x/budget_controller.dart';
import '../../../budget/presentation/widgets/budget_form_sheet.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';

/// Inline budget summary shown below the wallet strip on the Phân bổ tab.
///
/// Loads categories once on first build to resolve icons. The budget data comes
/// directly from the already-registered [BudgetController].
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
    // BudgetPage is no longer a top-level tab; ensure its controller is
    // registered before the first reactive read in this widget.
    if (!Get.isRegistered<BudgetController>()) {
      Get.put(getIt<BudgetController>());
    }
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
                  fontWeight: FontWeight.bold,
                  color: scheme.onBackground,
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
                    onTap: () => context.router.push(const BudgetRoute()),
                    child: CcText(
                      el.tr(CcLocaleKeys.budget_see_all),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(() {
          final budgets = Get.find<BudgetController>().budgets;
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
          return HorizontalFadeScrollView(
            height: context.respDim(120),
            builder: (scrollController) => ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
              ),
              itemCount: budgets.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: context.respDim(10)),
                child: SizedBox(
                  width: context.respDim(140),
                  child: _BudgetPreviewCard(
                    stats: budgets[index],
                    category: _categoryMap[budgets[index].budget.categoryId],
                  ),
                ),
              ),
            ),
          );
        }),
        SizedBox(height: context.respDim(24)),
      ],
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
      builder: (_) => const BudgetFormSheet(),
    );
  }
}

class _BudgetPreviewCard extends StatelessWidget {
  final BudgetStatsEntity stats;
  final CategoryEntity? category;

  const _BudgetPreviewCard({required this.stats, this.category});

  static const Color _amber = Color(0xFFF2A65A);

  static String _fmtShort(int value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}tỷ đ';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}tr đ';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k đ';
    return '$value đ';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final status = stats.status;
    final accent = switch (status) {
      BudgetStatus.over => scheme.error,
      BudgetStatus.nearLimit => _amber,
      BudgetStatus.safe => scheme.primary,
    };
    final pct = (stats.progress * 100).round();

    final iconColor = category?.color ?? scheme.primary;
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
                    backgroundColor: scheme.surfaceContainerHighest,
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
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          CcText(
            '$pct% đã dùng',
            align: Alignment.center,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          CcText(
            stats.isOver
                ? '− ${_fmtShort(stats.spent - stats.budget.limit)}'
                : 'còn ${_fmtShort(stats.remaining)}',
            align: Alignment.center,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
