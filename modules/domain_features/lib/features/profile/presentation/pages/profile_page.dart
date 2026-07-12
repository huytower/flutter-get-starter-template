import 'package:catcher_2/catcher_2.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/di.dart';
import '../../../category/export_category.dart';
import '../get_x/profile_controller.dart';
import '../widgets/profile_level_badge.dart';
import '../widgets/profile_settings_tile.dart';

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
    final current = (_c.settings.value.birthYear ?? now.year - 25)
        .clamp(minYear, maxYear);
    final currentDateLabel = DateFormat('EEE, MMM d').format(now);
    int temporaryYear = current;

    final picked = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
            vertical: context.respPadding(CcPaddingParams.PAGE_LG),
          ),
          backgroundColor: context.ccColorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.respDim(CcCircularParams.CARD),
            ),
          ),
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.ccColorScheme.primary,
                          context.ccColorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                          context.respDim(CcCircularParams.CARD),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      context.respPadding(CcPaddingParams.PAGE_SM),
                      context.respPadding(CcPaddingParams.SPACE_LG),
                      context.respPadding(CcPaddingParams.PAGE_SM),
                      context.respPadding(CcPaddingParams.SPACE_MD),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CcText(
                          'SELECT DATE',
                          textStyle: context.ccTextTheme.bodySmall?.copyWith(
                            color: context.ccColorScheme.onPrimary,
                            letterSpacing: 1.2,
                            fontWeight: CcTypographyParams.bold,
                          ),
                        ),
                        const CcSpaceMD(),
                        CcText(
                          currentDateLabel,
                          textStyle: context.ccTextTheme.headlineSmall?.copyWith(
                            color: context.ccColorScheme.onPrimary,
                            fontWeight: CcTypographyParams.bold,
                          ),
                        ),
                        const CcSpaceMD(),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: context.ccColorScheme.onPrimary.withOpacity(0.16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: context.ccColorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(
                          context.respDim(CcCircularParams.CARD),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                      vertical: context.respPadding(CcPaddingParams.SPACE_SM),
                    ),
                    child: SizedBox(
                      height: context.respDim(220),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          textTheme: Theme.of(context).textTheme.copyWith(
                                bodyMedium: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: context.ccColorScheme.onSurface,
                                    ),
                              ),
                        ),
                        child: YearPicker(
                          firstDate: DateTime(minYear),
                          lastDate: DateTime(maxYear),
                          selectedDate: DateTime(temporaryYear),
                          onChanged: (date) {
                            Navigator.of(dialogContext).pop(date.year);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (picked != null) await _c.setBirthYear(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.ccColorScheme.surface,
        body: StreamBuilder<CcUserEntity?>(
          stream: _c.userStream,
          builder: (context, snapshot) {
            final user = snapshot.data;
            final isLoggedIn = user != null;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, user),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CcSpaceMD(),
                        _buildStatsRow(context),
                        const CcSpaceMD(),
                        _buildMenuGroup(context, isLoggedIn),
                        if (isLoggedIn) ...[
                          const CcSpaceXL(),
                          _buildLogoutButton(context),
                          const CcSpaceSM(),
                          _buildDeleteAccountText(context),
                        ],
                        const CcSpaceXL(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CcUserEntity? user) {
    final name = _displayName(context, user);
    final subtitle = user != null
        ? user.email
        : el.tr(CcLocaleKeys.profile_not_logged_in);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.ccColorScheme.primary,
            context.ccColorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
            vertical: context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: context.respDim(28),
                backgroundColor: Colors.white,
                child: user?.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatarUrl!,
                          width: context.respDim(56),
                          height: context.respDim(56),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: context.respIconSize(baseSize: 30),
                        color: context.ccColorScheme.primary,
                      ),
              ),
              SizedBox(width: context.respDim(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CcText(
                      name,
                      textStyle: context.ccTextTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const CcSpaceXS(),
                    CcText(
                      subtitle,
                      textStyle: context.ccTextTheme.bodySmall?.copyWith(
                        color: CcBaseColors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const ProfileLevelBadge('LV1'),
            ],
          ),
        ),
      ),
    );
  }

  int get _daysToSunday {
    final daysLeft = 7 - DateTime.now().weekday;
    return daysLeft; // 0 when today is Sunday
  }

  Widget _buildStatsRow(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          context.respDim(CcCircularParams.CARD),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          context.respDim(CcCircularParams.CARD),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildStatCell(
                  context,
                  icon: Icons.access_time_rounded,
                  label: el.tr(CcLocaleKeys.profile_weekly_audit),
                  value: el.tr(
                    CcLocaleKeys.profile_days_left,
                    namedArgs: {'count': '$_daysToSunday'},
                  ),
                  valueColor: context.ccColorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildStatCell(
                  context,
                  icon: Icons.lock_rounded,
                  label: el.tr(CcLocaleKeys.profile_debt_loan),
                  value: el.tr(
                    CcLocaleKeys.profile_unlock_at_lv,
                    namedArgs: {'level': '3'},
                  ),
                  valueColor: context.ccColorScheme.onSurfaceVariant
                      .withOpacity(0.5),
                  isLocked: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isLocked = false,
  }) {
    final iconColor = isLocked
        ? context.ccColorScheme.onSurfaceVariant.withOpacity(0.5)
        : context.ccColorScheme.primary;
    return Padding(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: context.respIconSize(baseSize: 18),
              color: iconColor,
            ),
          ),
          SizedBox(height: context.respDim(4)),
          CcText(
            label,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
            align: Alignment.center,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.respDim(2)),
          CcText(
            value,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
            align: Alignment.center,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, bool isLoggedIn) {
    final items = _buildMenuItems(context, isLoggedIn);
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      rows.add(items[i]);
      if (i < items.length - 1) rows.add(const CcDividerHorizontalLine());
    }

    return Material(
      color: context.ccColorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(
        context.respDim(CcCircularParams.CARD),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, bool isLoggedIn) {
    return [
      // if (!isLoggedIn)
      //   ProfileSettingsTile(
      //     icon: Icons.person_add_rounded,
      //     label: el.tr(CcLocaleKeys.profile_register_login),
      //     onTap: () => getIt<AuthCoordinator>().navigateToLogin(context),
      //   ),
      ProfileSettingsTile(
        icon: Icons.tune_rounded,
        label: el.tr(CcLocaleKeys.category_settings_title),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<bool>(builder: (_) => const CategorySettingsPage()),
        ),
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.cake_rounded,
          label: 'Năm sinh',
          trailingLabel: _c.settings.value.birthYear?.toString() ?? 'Chưa đặt',
          onTap: () => _pickBirthYear(context),
        ),
      ),
      ProfileSettingsTile(
        icon: Icons.calendar_today_rounded,
        label: el.tr(CcLocaleKeys.profile_weekly_audit_day),
        trailingLabel: 'CN',
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.notifications_rounded,
          label: el.tr(CcLocaleKeys.profile_reminder),
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
      ProfileSettingsTile(
        icon: Icons.palette_rounded,
        label: el.tr(CcLocaleKeys.settings_theme),
        trailingLabel: 'Tĩnh',
      ),
      ProfileSettingsTile(
        icon: Icons.language_rounded,
        label: el.tr(CcLocaleKeys.settings_language),
        trailingLabel: 'Vietnamese',
      ),
      ProfileSettingsTile(
        icon: Icons.attach_money_rounded,
        label: el.tr(CcLocaleKeys.profile_currency),
        trailingLabel: 'Đồng',
      ),
      ProfileSettingsTile(
        icon: Icons.play_circle_outline_rounded,
        label: el.tr(CcLocaleKeys.profile_view_tutorial),
      ),
      ProfileSettingsTile(
        icon: Icons.description_rounded,
        label: el.tr(CcLocaleKeys.profile_terms),
      ),
      Obx(
        () => ProfileSettingsTile(
          icon: Icons.info_outline_rounded,
          label: el.tr(CcLocaleKeys.profile_about),
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
