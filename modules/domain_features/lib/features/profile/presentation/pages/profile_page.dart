import 'package:catcher_2/catcher_2.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

import '../../../../core/di/di.dart';
import '../../../category/export_category.dart';
import '../get_x/profile_controller.dart';
import '../widgets/birth_year_dialog.dart';
import '../widgets/language_selection_dialog.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_group.dart';
import '../widgets/profile_settings_tile.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/weekly_audit_day_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _c;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(getIt<ProfileController>());
    }
    _c = Get.find<ProfileController>();
  }

  void _openCrashLogViewer() {
    if (!CrashLogDevOverlay.isViewerEnabled) return;
    final navContext = Catcher2.navigatorKey.currentContext ?? context;
    CcDialogHelper.showModalBottomSheet(navContext, const CrashLogViewerPage());
  }

  Future<void> _pickBirthYear(BuildContext context) async {
    final now = DateTime.now();
    final minYear = now.year - 70;
    final maxYear = now.year - 10;
    final current = (_c.settings.value.birthYear ?? now.year - 25).clamp(
      minYear,
      maxYear,
    );

    final picked = await BirthYearDialog.show(
      context,
      currentYear: current,
      minYear: minYear,
      maxYear: maxYear,
    );

    if (picked != null) {
      final group = CategorySeed.ageGroup(picked);
      if (group != null) {
        await _c.setBirthYear(picked);
        await _enableCategories([
          ...CategorySeed.defaultExpenseCategoryKeys[group]!,
          ...CategorySeed.defaultIncomeCategoryKeys[group]!,
        ]);
      }
    }
  }

  /// Enables the given category `nameKey`s (mapped to their seed ids) so they
  /// appear checked in the category settings.
  Future<void> _enableCategories(List<String> keys) async {
    final useCase = getIt<ToggleCategoryEnabledUseCase>();
    final idByKey = {for (final c in CategorySeed.categories) c.nameKey: c.id};
    for (final key in keys) {
      final id = idByKey[key];
      if (id != null) await useCase.call(id, true);
    }
  }

  Future<void> _pickWeeklyAuditDay(BuildContext context) async {
    final current =
        _c.settings.value.weeklyAuditDayIndex + 1; // 0-indexed to 1-indexed

    final picked = await WeeklyAuditDayDialog.show(
      context,
      currentDay: current,
    );

    if (picked != null) await _c.setWeeklyAuditDay(picked - 1);
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final picked = await LanguageSelectionDialog.show(context);
    if (picked != null && context.mounted) {
      await el.EasyLocalization.of(context)!.setLocale(picked);
    }
  }

  Future<void> _toggleTheme(bool isDarkMode) async {
    final themeProvider = context.read<ThemeProvider>();
    themeProvider.toggleTheme(isDarkMode);
    await _c.setThemeMode(isDarkMode);
  }

  String _getDayName(int day) {
    final names = el.tr(CcLocaleKeys.common_weekday_names).split('|');
    if (day >= 1 && day <= 7) {
      return names[day - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.ccColorScheme.background,
        body: StreamBuilder<CcUserEntity?>(
          stream: _c.userStream,
          builder: (context, snapshot) {
            final user = snapshot.data;
            final isLoggedIn = user != null;

            return Stack(
              children: [
                const BgGradientWidget(),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeader(
                        user: user,
                        displayName: _displayName(context, user),
                      ),
                      CcSymmetricPadding(
                        horizontal: CcPaddingParams.PAGE_SM,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const CcSpaceMD(),
                            ProfileStatsRow(daysToSunday: _daysToSunday),
                            const CcSpaceMD(),
                            ProfileMenuGroup(
                              items: _buildMenuItems(context, isLoggedIn),
                            ),
                            const CcSpaceXL(),
                            if (isLoggedIn) ...[
                              _buildLogoutButton(context),
                              const CcSpaceLG(),
                              _buildDeleteAccountText(context),
                            ],
                            const CcSpaceXL(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int get _daysToSunday {
    final daysLeft = 7 - DateTime.now().weekday;
    return daysLeft; // 0 when today is Sunday
  }

  List<Widget> _buildMenuItems(BuildContext context, bool isLoggedIn) {
    return [
      ProfileSettingsTile(
        icon: Icons.tune_rounded,
        label: el.tr(CcLocaleKeys.category_settings_title),
        subtitle: el.tr(CcLocaleKeys.category_settings_subtitle),
        onTap: () async {
          if (_c.settings.value.birthYear == null) {
            await _pickBirthYear(context);
            if (_c.settings.value.birthYear == null) return;
          }
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (_) => const CategorySettingsPage(),
            ),
          );
        },
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.cake_rounded,
          label: el.tr(CcLocaleKeys.profile_birth_year),
          subtitle: el.tr(CcLocaleKeys.profile_birth_year_subtitle),
          trailingLabel:
              _c.settings.value.birthYear?.toString() ??
              el.tr(CcLocaleKeys.common_not_set),
          onTap: () => _pickBirthYear(context),
        ),
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.calendar_today_rounded,
          label: el.tr(CcLocaleKeys.profile_weekly_audit_day),
          subtitle: el.tr(CcLocaleKeys.profile_weekly_audit_day_subtitle),
          trailingLabel: _getDayName(_c.settings.value.weeklyAuditDayIndex + 1),
          onTap: () => _pickWeeklyAuditDay(context),
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
                value: _c.settings.value.reminderEnabled,
                onChanged: _c.toggleReminder,
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
                value: _c.settings.value.isDarkMode,
                onChanged: _toggleTheme,
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
        trailingLabel: context.locale.languageCode == 'vi'
            ? el.tr(CcLocaleKeys.settings_language_vietnamese)
            : el.tr(CcLocaleKeys.settings_language_english),
        onTap: () => _pickLanguage(context),
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
          trailingLabel: _c.appVersion.value.isEmpty
              ? null
              : 'v${_c.appVersion.value}',
          showChevron: false,
          onLongPress: _openCrashLogViewer,
        ),
      ),
    ];
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CcBaseBtn(
      onTap: () => _c.logout(context),
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
      onTap: () {
        // TODO(profile): show confirmation dialog then call delete account use case
      },
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

  String _displayName(BuildContext context, CcUserEntity? user) {
    if (user == null) return el.tr(CcLocaleKeys.profile_guest);
    final parts = [
      user.firstName,
      user.lastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    return parts.isNotEmpty ? parts : user.email;
  }
}
