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

class CategorySettingsPage extends CcGetView<CategorySettingsController> {
  const CategorySettingsPage({super.key});

  @override
  bool get enableAppBar => false;

  @override
  Widget buildContent(BuildContext context) {
    // Manually register if needed, although normally handled by Binding or Get.put in parent
    if (!Get.isRegistered<CategorySettingsController>()) {
      Get.put(getIt<CategorySettingsController>());
    }

    return Scaffold(
      backgroundColor: context.ccColorScheme.surface,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
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
      controller.pending.keys.length; // Access to trigger Obx on toggle changes
      final groups = controller.groups;
      final byGroup = controller.byGroup;
      final incomeByGroup = controller.incomeByGroup;

      return ListView.builder(
        padding: EdgeInsets.only(bottom: context.respDim(100)),
        itemCount: 1 + groups.length + 1 + CategorySeed.incomeGroups.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(
              context,
              el.tr(CcLocaleKeys.category_expense_settings_title),
            );
          }
          final expenseIndex = index - 1;
          if (expenseIndex < groups.length) {
            final group = groups[expenseIndex];
            final cats = byGroup[group.id] ?? [];
            if (cats.isEmpty) return const SizedBox.shrink();
            return CategoryGroupSection(
              group: group,
              categories: cats,
              isEnabled: (cat) {
                controller.pending.keys.length; // Access to trigger Obx
                return controller.isEnabled(cat);
              },
              onToggle: controller.toggle,
              accentColor: context.ccColorScheme.error,
            );
          }
          if (expenseIndex == groups.length) {
            return _buildHeader(
              context,
              el.tr(CcLocaleKeys.category_income_settings_title),
              topPadding: 24,
            );
          }
          final incomeIndex = expenseIndex - groups.length - 1;
          final group = CategorySeed.incomeGroups[incomeIndex];
          final cats = incomeByGroup[group.id] ?? [];
          if (cats.isEmpty) return const SizedBox.shrink();
          return CategoryGroupSection(
            group: group,
            categories: cats,
            isEnabled: (cat) {
              controller.pending.keys.length; // Access to trigger Obx
              return controller.isEnabled(cat);
            },
            onToggle: controller.toggle,
            accentColor: PrjColors.success,
          );
        },
      );
    });
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
          fontWeight: FontWeight.bold,
          color: context.ccColorScheme.primary,
        ),
      ),
    );
  }
}
