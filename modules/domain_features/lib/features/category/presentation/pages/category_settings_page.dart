import 'package:flutter/material.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_view.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../data/datasources/local/category_seed.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/category_group_entity.dart';
import '../get_x/category_settings_controller.dart';

class CategorySettingsPage extends StatefulWidget {
  const CategorySettingsPage({super.key});

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CategorySettingsController>()) {
      Get.put(getIt<CategorySettingsController>());
    } else {
      Get.find<CategorySettingsController>().load();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<GuidelineController>()) {
        Get.find<GuidelineController>().completeTask('categories');
      }
    });
  }

  @override
  Widget build(BuildContext context) => const _CategorySettingsView();
}

class _CategorySettingsView extends CcGetView<CategorySettingsController> {
  const _CategorySettingsView();

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return _buildAppBar(context);
  }

  @override
  Widget buildContent(BuildContext context) {
    return _buildBody(context);
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) {
    return Container(color: context.ccColorScheme.surface, child: body);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
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
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.layoutStatus.value == CcLayoutStatus.loading) {
        return const Center(child: CcLoadingIconWidget());
      }
      return FadePageWrapper(
        child: Column(
          children: [
            const CcSpaceSM(),
            _buildSubtitle(context),
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.ccColorScheme.surface,
                      context.ccColorScheme.surface,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.92, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: _buildCategoryList(context),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubtitle(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: CcText(
        el.tr(CcLocaleKeys.category_settings_subtitle),
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(80),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return Obx(() {
      // Need to access pending to trigger rebuild on toggle
      controller.pending.length;
      final groups = controller.groups;
      const incomeGroups = CategorySeed.incomeGroups;
      const investmentGroups = CategorySeed.investmentGroups;
      const liabilityGroups = CategorySeed.liabilityGroups;

      final status = getIt<UserLevelController>().status.value;

      final sections = <Widget>[];

      sections.add(
        _buildHeader(
          context,
          el.tr(CcLocaleKeys.category_expense_settings_title),
        ),
      );
      for (final group in groups) {
        final groupWidget = _buildExpenseGroup(context, group);
        if (groupWidget is! SizedBox) {
          sections.add(groupWidget);
        }
      }

      sections.add(
        _buildHeader(
          context,
          el.tr(CcLocaleKeys.category_income_settings_title),
          topPadding: 24,
        ),
      );
      for (final group in incomeGroups) {
        final groupWidget = _buildIncomeGroup(context, group);
        if (groupWidget is! SizedBox) {
          sections.add(groupWidget);
        }
      }

      if (status.canUseInvestment) {
        sections.add(
          _buildHeader(
            context,
            el.tr(CcLocaleKeys.category_investment_settings_title),
            topPadding: 24,
          ),
        );
        for (final group in investmentGroups) {
          final groupWidget = _buildInvestmentGroup(context, group);
          if (groupWidget is! SizedBox) {
            sections.add(groupWidget);
          }
        }
      }

      if (status.canUseLiability) {
        sections.add(
          _buildHeader(
            context,
            el.tr(CcLocaleKeys.category_debt_loan_settings_title),
            topPadding: 24,
          ),
        );
        for (final group in liabilityGroups) {
          final groupWidget = _buildLiabilityGroup(context, group);
          if (groupWidget is! SizedBox) {
            sections.add(groupWidget);
          }
        }
      }

      return ListView.builder(
        padding: EdgeInsets.only(bottom: context.respDim(100)),
        itemCount: sections.length,
        itemBuilder: (context, index) => sections[index],
      );
    });
  }

  Widget _buildExpenseGroup(BuildContext context, CategoryGroupEntity group) {
    final cats = controller.byGroup[group.id] ?? [];
    if (cats.isEmpty) return const SizedBox.shrink();
    return _buildGroupSection(
      group: group,
      categories: cats,
      accentColor: context.ccColorScheme.error,
    );
  }

  Widget _buildIncomeGroup(BuildContext context, CategoryGroupEntity group) {
    final cats = controller.incomeByGroup[group.id] ?? [];
    if (cats.isEmpty) return const SizedBox.shrink();
    return _buildGroupSection(
      group: group,
      categories: cats,
      accentColor: PrjColors.success,
    );
  }

  Widget _buildLiabilityGroup(BuildContext context, CategoryGroupEntity group) {
    var cats = controller.liabilityByGroup[group.id] ?? [];
    if (cats.isEmpty) {
      cats = controller.liabilityByGroup.values.expand((e) => e).toList();
    }

    if (cats.isEmpty) return const SizedBox.shrink();
    return _buildGroupSection(
      group: group,
      categories: cats,
      accentColor: context.ccColorScheme.liability,
    );
  }

  Widget _buildInvestmentGroup(
    BuildContext context,
    CategoryGroupEntity group,
  ) {
    final cats = controller.investmentByGroup[group.id] ?? [];
    if (cats.isEmpty) return const SizedBox.shrink();
    return _buildGroupSection(
      group: group,
      categories: cats,
      accentColor: context.ccColorScheme.investment,
    );
  }

  Widget _buildGroupSection({
    required CategoryGroupEntity group,
    required List<CategoryEntity> categories,
    required Color accentColor,
  }) {
    return CcCategoryGroupSection(
      items: categories
          .map(
            (c) => CcCategoryGroupItem(
              labelKey: c.nameKey,
              iconCode: c.iconCode,
              iconFamily: c.iconFamily,
              originalData: c,
            ),
          )
          .toList(),
      isEnabled: (item) =>
          controller.isEnabled(item.originalData as CategoryEntity),
      onToggle: (item) =>
          controller.toggle(item.originalData as CategoryEntity),
      accentColor: accentColor,
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title, {
    double topPadding = 8,
  }) {
    return CcPadding(
      CcText(
        title,
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          fontWeight: CcTypographyParams.bold,
          color: context.ccColorScheme.primary,
        ),
      ),
      CcPaddingParams.TITLE_XS,
      CcPaddingParams.PAGE_SM,
      CcPaddingParams.PAGE_SM,
      CcPaddingParams.TITLE_MD,
    );
  }
}
