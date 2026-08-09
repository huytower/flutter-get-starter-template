import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:domain_features/core/getx/cc_get_view.dart';
import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../get_x/profile_controller.dart';
import '../widgets/guideline_reset_bottom_sheet.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_group.dart';
import '../widgets/profile_settings_tile.dart';
import '../widgets/profile_stats_row.dart';

class ProfilePage extends CcGetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  bool get enableAppBar => false;

  @override
  Widget buildContent(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.openBirthYearPicker.value) {
        controller.pickBirthYear(context);
        controller.openBirthYearPicker.value = false;
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.ccColorScheme.background,
        body: Stack(
          children: [
            const BgGradientWidget(),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() {
                    'Rebuilding ProfileHeader with user: ${controller.user.value?.id}'
                        .Log('ProfilePage');
                    return Hero(
                      tag: 'profile_hero_banner',
                      child: ProfileHeader(
                        user: controller.user.value,
                        displayName: controller.displayName,
                        level: controller.userLevel.status.value.level,
                        onTap: () => controller.handleHeroBannerTap(context),
                        onEditName: () => controller.pickDisplayName(context),
                      ),
                    );
                  }),
                  CcSymmetricPadding(
                    horizontal: CcPaddingParams.PAGE_SM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CcSpaceMD(),
                        Obx(
                          () => ProfileStatsRow(
                            daysToNextAudit: controller.daysToNextAudit,
                            levelStatus: controller.userLevel.status.value,
                          ),
                        ),
                        const CcSpaceMD(),
                        ProfileMenuGroup(items: _buildMenuItems(context)),
                        const CcSpaceXL(),
                        Obx(
                          () => controller.isLoggedIn
                              ? Column(
                                  children: [
                                    _buildLogoutButton(context),
                                    const CcSpaceLG(),
                                    _buildDeleteAccountText(context),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        const CcSpaceXL(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final guideline = Get.find<GuidelineController>();

    final color = guideline.currentColor;

    return [
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.tune_rounded,
          label: el.tr(CcLocaleKeys.category_settings_title),
          subtitle: el.tr(CcLocaleKeys.category_settings_subtitle),
          onTap: () => controller.navigateToCategorySettings(context),
          badge: guideline.isTaskActive('categories')
              ? CcGuidelineBadge(
                  size: 8,
                  color: color,
                  bounceTrigger: guideline.bounceTrigger,
                )
              : null,
        ),
      ),
      ProfileSettingsTile(
        icon: Icons.link_rounded,
        label: el.tr(CcLocaleKeys.profile_link_account_title),
        subtitle: el.tr(CcLocaleKeys.profile_link_account_subtitle),
        onTap: () => controller.navigateToLinkAccount(context),
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.cake_rounded,
          label: el.tr(CcLocaleKeys.profile_birth_year),
          subtitle: el.tr(CcLocaleKeys.profile_birth_year_subtitle),
          trailingLabel:
              controller.settings.value.birthYear?.toString() ??
              el.tr(CcLocaleKeys.common_not_set),
          onTap: () => controller.pickBirthYear(context),
          badge: guideline.isTaskActive('birth_year')
              ? CcGuidelineBadge(
                  size: 8,
                  color: color,
                  bounceTrigger: guideline.bounceTrigger,
                )
              : null,
        ),
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.calendar_today_rounded,
          label: el.tr(CcLocaleKeys.profile_weekly_audit_day),
          subtitle: el.tr(CcLocaleKeys.profile_weekly_audit_day_subtitle),
          trailingLabel: controller.weeklyAuditDayName,
          onTap: () => controller.pickWeeklyAuditDay(context),
        ),
      ),
      // Debug-only escape hatches for QA to bypass VIP/LV1-3 gating without
      // real IAP/billing infra. Must never reach real users, so they're only
      // built in debug binaries (kDebugMode is compiled out of profile/release).
      if (kDebugMode) ...[
        Obx(
          () => ProfileSettingsTile(
            icon: Icons.workspace_premium_rounded,
            label: el.tr(CcLocaleKeys.profile_vip),
            subtitle: el.tr(CcLocaleKeys.profile_vip_subtitle),
            showChevron: false,
            trailingWidget: SizedBox(
              height: context.respIconSize(baseSize: 20),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Switch(
                  value: controller.settings.value.isVip,
                  onChanged: controller.setVip,
                  activeColor: context.ccColorScheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ),
        Obx(
          () => ProfileSettingsTile(
            icon: Icons.lock_open_rounded,
            label: el.tr(CcLocaleKeys.profile_force_full_access),
            subtitle: el.tr(CcLocaleKeys.profile_force_full_access_subtitle),
            showChevron: false,
            trailingWidget: SizedBox(
              height: context.respIconSize(baseSize: 20),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Switch(
                  value: controller.settings.value.forceFullAccess,
                  onChanged: controller.setForceFullAccess,
                  activeColor: context.ccColorScheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ),
      ],
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.notifications_rounded,
          label: el.tr(CcLocaleKeys.profile_reminder),
          subtitle: el.tr(CcLocaleKeys.profile_reminder_subtitle),
          showChevron: false,
          trailingWidget: SizedBox(
            height: context.respIconSize(baseSize: 20),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: controller.settings.value.reminderEnabled,
                onChanged: controller.toggleReminder,
                activeColor: context.ccColorScheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.palette_rounded,
          label: el.tr(CcLocaleKeys.settings_theme),
          subtitle: el.tr(CcLocaleKeys.profile_theme_subtitle),
          showChevron: false,
          trailingWidget: SizedBox(
            height: context.respIconSize(baseSize: 20),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: controller.settings.value.isDarkMode ?? false,
                onChanged: controller.setThemeMode,
                activeColor: context.ccColorScheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ),
      ProfileSettingsTile(
        icon: Icons.language_rounded,
        label: el.tr(CcLocaleKeys.settings_language),
        subtitle: el.tr(CcLocaleKeys.profile_language_subtitle),
        trailingLabel: controller.currentLanguageName(context),
        onTap: () => controller.pickLanguage(context),
      ),
      ProfileSettingsTile(
        icon: Icons.attach_money_rounded,
        label: el.tr(CcLocaleKeys.profile_currency),
        subtitle: el.tr(CcLocaleKeys.profile_currency_subtitle),
        trailingLabel: el.tr(CcLocaleKeys.profile_currency_dong),
      ),
      ProfileSettingsTile(
        icon: Icons.play_circle_outline_rounded,
        label: el.tr(CcLocaleKeys.profile_view_tutorial),
        subtitle: el.tr(CcLocaleKeys.profile_view_tutorial_subtitle),
        onTap: () {
          final count = guideline.completedTasks.length;
          final desc = el.tr(
            CcLocaleKeys.guideline_reset_confirm_desc,
            namedArgs: {'count': count.toString()},
          );
          GuidelineResetBottomSheet.show(
            context,
            desc: desc,
            count: count,
            onConfirm: () => guideline.resetGuideline(),
          );
        },
      ),
      ProfileSettingsTile(
        icon: Icons.description_rounded,
        label: el.tr(CcLocaleKeys.profile_terms),
        subtitle: el.tr(CcLocaleKeys.profile_terms_subtitle),
        onTap: () => controller.navigateToTerms(context),
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.info_outline_rounded,
          label: el.tr(CcLocaleKeys.profile_about),
          subtitle: el.tr(CcLocaleKeys.profile_about_subtitle),
          trailingLabel: controller.appVersion.value.isEmpty
              ? null
              : 'v${controller.appVersion.value}',
          showChevron: false,
          onLongPress: () => controller.openCrashLogViewer(context),
        ),
      ),
    ];
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CcBaseBtn(
      onTap: () => controller.logout(context),
      title: el.tr(CcLocaleKeys.auth_logout),
      bgColor: [
        context.ccColorScheme.surfaceContainerHighest,
        context.ccColorScheme.surfaceContainerHighest,
      ],
      textColor: context.ccColorScheme.onSurface,
    );
  }

  Widget _buildDeleteAccountText(BuildContext context) {
    return GestureDetector(
      onTap: controller.deleteAccount,
      child: CcText(
        el.tr(CcLocaleKeys.profile_delete_account),
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: context.ccColorScheme.error,
          fontWeight: FontWeight.w500,
        ),
        align: Alignment.center,
        textAlign: TextAlign.center,
      ),
    );
  }
}
