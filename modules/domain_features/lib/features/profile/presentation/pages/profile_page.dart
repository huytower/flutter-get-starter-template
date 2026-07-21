import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../get_x/profile_controller.dart';
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
                        onTap: () => controller.handleHeroBannerTap(context),
                      ),
                    );
                  }),
                  CcSymmetricPadding(
                    horizontal: CcPaddingParams.PAGE_SM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CcSpaceMD(),
                        ProfileStatsRow(daysToSunday: controller.daysToSunday),
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
    return [
      ProfileSettingsTile(
        icon: Icons.tune_rounded,
        label: el.tr(CcLocaleKeys.category_settings_title),
        subtitle: el.tr(CcLocaleKeys.category_settings_subtitle),
        onTap: () => controller.navigateToCategorySettings(context),
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
                value: controller.settings.value.isDarkMode,
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
      ),
      ProfileSettingsTile(
        icon: Icons.description_rounded,
        label: el.tr(CcLocaleKeys.profile_terms),
        subtitle: el.tr(CcLocaleKeys.profile_terms_subtitle),
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
