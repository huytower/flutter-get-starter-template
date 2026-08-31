import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/core/getx/cc_get_view.dart';
import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:multiple_result/multiple_result.dart';

import '../get_x/profile_controller.dart';
import '../widgets/guideline_reset_bottom_sheet.dart';
import '../widgets/profile_delete_confirm_sheet.dart';
import '../widgets/profile_menu_group.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_settings_tile.dart';

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
                  const CcSpaceMD(),
                  Obx(() {
                    return Hero(
                      tag: 'profile_hero_banner',
                      child: ProfilePageHeader(
                        user: controller.user.value,
                        displayName: controller.displayName,
                        level: controller.userLevel.status.value.level,
                        daysToNextAudit: controller.daysToNextAudit,
                        levelStatus: controller.userLevel.status.value,
                        initialFlipped:
                            controller.settings.value.isHeaderFlipped,
                        onFlip: controller.setHeaderFlipped,
                        onEditName: () => controller.pickDisplayName(context),
                        onLinkAccount: () =>
                            controller.handleLinkAccountTap(context),
                        onAvatarTap: () => controller.handleAvatarTap(context),
                        onLinkPhone: () =>
                            controller.handlePhoneLinkTap(context),
                      ),
                    );
                  }),
                  CcSymmetricPadding(
                    horizontal: CcPaddingParams.PAGE_SM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CcSpaceMD(),
                        ProfileMenuGroup(items: _buildMenuItems(context)),
                        const CcSpaceXL(),
                        Obx(
                          () => controller.isLoggedIn
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildDeleteAccountText(context),
                                    const CcSpaceSM(),
                                    _buildLogoutButton(context),
                                    const CcSpaceMD(),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        _buildFooter(context),
                        const CcSpaceXS(),
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
                  label: guideline.bannerDescription,
                  isDescriptionHidden: guideline.isDescriptionHidden.value,
                  onLabelTap: () => guideline.isDescriptionHidden.value = true,
                  growRight: true,
                )
              : null,
        ),
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
                  label: guideline.bannerDescription,
                  isDescriptionHidden: guideline.isDescriptionHidden.value,
                  onLabelTap: () => guideline.isDescriptionHidden.value = true,
                  growRight: true,
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
    ];
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CcBouncing(
      onTap: () => controller.logout(context),
      child: CcText(
        el.tr(CcLocaleKeys.auth_logout),
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        align: Alignment.center,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDeleteAccountText(BuildContext context) {
    return CcBouncing(
      onTap: () async {
        final result = await showModalBottomSheet<Result<Unit, CcFailure>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => ProfileDeleteConfirmSheet(
            onConfirm: (sheetContext) => controller.deleteAccount(),
          ),
        );

        if (result == null) return;

        result.when(
          (success) {
            // After delete success, we stay on this page.
            // The Obx wrappers will automatically refresh the UI to the
            // Guest state because session.clearSession() was called.
          },
          (failure) {
            if (context.mounted) {
              CcSnackBarHelper.showErrorSnackBar(
                context: context,
                message: failure.message,
              );
            }
          },
        );
      },
      child: CcText(
        el.tr(CcLocaleKeys.profile_delete_account),
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        align: Alignment.center,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final scheme = context.ccColorScheme;
    final textTheme = context.ccTextTheme;

    return Column(
      children: [
        const CcSpaceSM(),
        CcText(
          el.tr(CcLocaleKeys.app_slogan),
          maxLines: 2,
          textStyle: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
          align: Alignment.center,
        ),
        const CcSpaceXS(),
        _buildContactBox(
          context,
          role: el.tr(CcLocaleKeys.app_role_hr),
          name: el.tr(CcLocaleKeys.app_author_hr_name),
          email: el.tr(CcLocaleKeys.app_author_hr_email),
        ),
        _buildContactBox(
          context,
          role: el.tr(CcLocaleKeys.app_role_tech),
          name: el.tr(CcLocaleKeys.app_author_tech_name),
          email: el.tr(CcLocaleKeys.app_author_tech_email),
        ),
        GestureDetector(
          onLongPress: () => controller.openCrashLogViewer(context),
          child: CcText(
            el.tr(CcLocaleKeys.app_address),
            textStyle: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
            align: Alignment.center,
          ),
        ),
      ],
    );
  }

  Widget _buildContactBox(
    BuildContext context, {
    required String role,
    required String name,
    required String email,
  }) {
    final scheme = context.ccColorScheme;
    final textTheme = context.ccTextTheme;
    final baseStyle = textTheme.labelSmall ?? const TextStyle();

    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: email));
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.app_copied_email,
            namedArgs: {'email': email},
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                text: '$role · ',
                style: baseStyle.copyWith(color: scheme.onSurface),
                children: [
                  TextSpan(
                    text: email,
                    style: baseStyle.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const CcSpaceXS(),
          Icon(
            Icons.copy_rounded,
            size: 16,
            color: scheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
