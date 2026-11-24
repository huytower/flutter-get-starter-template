import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/get_x/prj_get_view.dart';
import '../../../../core/presentation/widgets/category/prj_category_group_section.dart';
import '../../data/datasources/local/category_seed.dart';
import '../../domain/entities/category_group_entity.dart';
import '../get_x/category_settings_controller.dart';

class CategorySettingsPage extends StatefulWidget {
  const CategorySettingsPage({super.key, this.initialSection});

  /// [CategoryType] of the section to scroll to once the list is ready (e.g.
  /// [CategoryType.income] when opened from the Income form). Null keeps the
  /// list at the top.
  final String? initialSection;

  /// Pushes the page, optionally scrolled to [initialSection].
  static Future<bool?> open(BuildContext context, {String? initialSection}) {
    return Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => CategorySettingsPage(initialSection: initialSection),
      ),
    );
  }

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  /// One key per section header, by [CategoryType], so a section can be
  /// scrolled into view.
  final Map<String, GlobalKey> _sectionKeys = {
    CategoryType.expense: GlobalKey(debugLabel: 'category_section_expense'),
    CategoryType.income: GlobalKey(debugLabel: 'category_section_income'),
    CategoryType.investment: GlobalKey(
      debugLabel: 'category_section_investment',
    ),
    CategoryType.liability: GlobalKey(debugLabel: 'category_section_liability'),
  };

  Worker? _layoutStatusWorker;
  bool _initialSectionRevealed = false;

  @override
  void initState() {
    super.initState();
    final CategorySettingsController controller;
    if (!Get.isRegistered<CategorySettingsController>()) {
      controller = Get.put(getIt<CategorySettingsController>());
    } else {
      controller = Get.find<CategorySettingsController>()..load();
    }

    // The list only exists once loading finishes, so try now and again on
    // every status change until the target header has been laid out.
    if (widget.initialSection != null) {
      _layoutStatusWorker = ever(
        controller.layoutStatus,
        (_) => _revealInitialSection(),
      );
      _revealInitialSection();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (getIt<GuidelineProvider>().hasAvailable) {
        getIt<GuidelineProvider>().completeTask('categories');
      }
    });
  }

  /// Scrolls to the requested section header once it has been laid out.
  ///
  /// The header is not in the tree right after loading finishes: the list
  /// sits inside a `CcFadePageWrapper`, which only builds its child ~50ms after
  /// mounting. So keep retrying for a short while instead of giving up on the
  /// first miss.
  void _revealInitialSection([int attemptsLeft = 20]) {
    if (!mounted || _initialSectionRevealed) return;

    final controller = Get.find<CategorySettingsController>();
    // On the very first open the status is not `loading` yet and the list is
    // still empty; scrolling then would be undone by the reload that follows.
    final hasLoading =
        controller.layoutStatus.value == CcLayoutStatus.loading ||
        controller.groups.isEmpty;
    final headerContext = hasLoading
        ? null
        : _sectionKeys[widget.initialSection]?.currentContext;

    if (headerContext == null) {
      // While loading, the status worker calls back in once it finishes.
      if (hasLoading || attemptsLeft <= 0) return;
      Future.delayed(
        const Duration(milliseconds: 50),
        () => _revealInitialSection(attemptsLeft - 1),
      );
      return;
    }

    _initialSectionRevealed = true;
    Scrollable.ensureVisible(
      headerContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _layoutStatusWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _CategorySettingsView(sectionKeys: _sectionKeys);
}

class _CategorySettingsView extends PrjGetView<CategorySettingsController> {
  const _CategorySettingsView({required this.sectionKeys});

  final Map<String, GlobalKey> sectionKeys;

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
          el.tr(PrjLocaleKeys.category_settings_title),
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
      return CcFadePageWrapper(
        child: Column(
          children: [
            const CcSpaceMD(),
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
        el.tr(PrjLocaleKeys.category_settings_subtitle),
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

      final status = getIt<UserLevelProvider>().status;

      final sections = <Widget>[];

      sections.add(
        _buildHeader(
          context,
          el.tr(PrjLocaleKeys.category_expense_settings_title),
          key: sectionKeys[CategoryType.expense],
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
          el.tr(PrjLocaleKeys.category_income_settings_title),
          key: sectionKeys[CategoryType.income],
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
            el.tr(PrjLocaleKeys.category_investment_settings_title),
            key: sectionKeys[CategoryType.investment],
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
            el.tr(PrjLocaleKeys.category_debt_loan_settings_title),
            key: sectionKeys[CategoryType.liability],
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

      // Built eagerly (not a lazy ListView) so every section header is laid
      // out and can be scrolled to; the list is a few dozen rows at most.
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: context.respDim(100)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sections,
        ),
      );
    });
  }

  Widget _buildExpenseGroup(BuildContext context, CategoryGroupEntity group) {
    final cats = controller.byGroup[group.id] ?? [];
    if (cats.isEmpty) return const SizedBox.shrink();
    return _buildGroupSection(
      group: group,
      categories: cats,
      accentColor: context.expenseAccent,
    );
  }

  Widget _buildIncomeGroup(BuildContext context, CategoryGroupEntity group) {
    final cats = controller.incomeByGroup[group.id] ?? [];
    if (cats.isEmpty) return const SizedBox.shrink();
    return _buildGroupSection(
      group: group,
      categories: cats,
      accentColor: context.incomeAccent,
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
      accentColor: context.borrowAccent,
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
      accentColor: context.investmentAccent,
    );
  }

  Widget _buildGroupSection({
    required CategoryGroupEntity group,
    required List<CategoryEntity> categories,
    required Color accentColor,
  }) {
    return PrjCategoryGroupSection(
      items: categories
          .map(
            (c) => PrjCategoryGroupItem(
              label: el.tr(c.nameKey),
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
    Key? key,
    double topPadding = 8,
  }) {
    return CcPadding(
      key: key,
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
