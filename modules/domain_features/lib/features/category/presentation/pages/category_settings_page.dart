import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_view.dart';
import '../get_x/category_settings_controller.dart';
import '../widgets/category_group_section.dart';

class CategorySettingsPage extends StatefulWidget {
  const CategorySettingsPage({super.key});

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  @override
  void initState() {
    super.initState();
    // CategorySettingsController is a permanent GetX singleton (see
    // CcGetView.build()) whose onInit()/load() only fires the first time
    // this page is ever opened in the app session. Categories toggled
    // elsewhere (e.g. ProfileController.pickBirthYear's age-based defaults)
    // persist to Hive correctly but never reach this already-loaded
    // instance, so reload explicitly on every subsequent visit. Get.put()
    // itself already triggers onInit() -> load() on first registration, so
    // only the already-registered case needs an explicit call here.
    if (!Get.isRegistered<CategorySettingsController>()) {
      Get.put(getIt<CategorySettingsController>());
    } else {
      Get.find<CategorySettingsController>().load();
    }
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
      vertical: CcPaddingParams.SPACE_SM,
      child: CcText(
        el.tr(CcLocaleKeys.category_settings_subtitle),
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return Obx(() {
      controller.pending.length;
      final groups = controller.groups;
      const incomeGroups = CategorySeed.incomeGroups;
      const investmentGroups = CategorySeed.investmentGroups;
      const debtLoanGroups = CategorySeed.debtLoanGroups;

      final sections = <Widget>[];

      // 1. Expense Section
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

      // 2. Income Section
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

      // 3. Investment Section
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

      // 4. Debt & Loan Section
      sections.add(
        _buildHeader(
          context,
          el.tr(CcLocaleKeys.category_debt_loan_settings_title),
          topPadding: 24,
        ),
      );
      for (final group in debtLoanGroups) {
        final groupWidget = _buildDebtLoanGroup(context, group);
        if (groupWidget is! SizedBox) {
          sections.add(groupWidget);
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

  Widget _buildDebtLoanGroup(BuildContext context, CategoryGroupEntity group) {
    // Check both group ID and any categories of this type as a fallback
    var cats = controller.debtLoanByGroup[group.id] ?? [];
    if (cats.isEmpty) {
      // Fallback: Just get all debtLoan type categories regardless of group
      cats = controller.debtLoanByGroup.values.expand((e) => e).toList();
    }

    if (cats.isEmpty) return const SizedBox.shrink();
    return _buildGroupSection(
      group: group,
      categories: cats,
      accentColor: context.ccColorScheme.debtLoan,
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
    return CategoryGroupSection(
      group: group,
      categories: categories,
      isEnabled: (cat) {
        controller.pending.length;
        return controller.isEnabled(cat);
      },
      onToggle: controller.toggle,
      accentColor: accentColor,
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title, {
    double topPadding = 8,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.respPadding(topPadding),
        left: context.respPadding(CcPaddingParams.PAGE_SM),
        right: context.respPadding(CcPaddingParams.PAGE_SM),
        bottom: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: CcText(
        title,
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          fontWeight: CcTypographyParams.bold,
          color: context.ccColorScheme.primary,
        ),
      ),
    );
  }
}
