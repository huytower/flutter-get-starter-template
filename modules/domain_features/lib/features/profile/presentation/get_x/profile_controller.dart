import 'package:catcher_2/catcher_2.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../category/export_category.dart';
import '../../domain/entities/profile_settings_entity.dart';
import '../../domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/usecases/update_profile_settings_usecase.dart';
import '../widgets/birth_year_dialog.dart';
import '../widgets/language_selection_dialog.dart';
import '../widgets/weekly_audit_day_dialog.dart';

@lazySingleton
class ProfileController extends CcGetController {
  ProfileController(
    this._getSettings,
    this._updateSettings,
    this._toggleCategoryEnabled,
    this._session,
    this._deviceInfo,
    this._authCoordinator,
  );

  final GetProfileSettingsUseCase _getSettings;
  final UpdateProfileSettingsUseCase _updateSettings;
  final ToggleCategoryEnabledUseCase _toggleCategoryEnabled;
  final SessionContract _session;
  final CcDeviceInfoHelper _deviceInfo;
  final AuthCoordinator _authCoordinator;

  final Rxn<CcUserEntity> user = Rxn<CcUserEntity>();
  final Rx<ProfileSettingsEntity> settings = const ProfileSettingsEntity().obs;
  final RxString appVersion = ''.obs;
  final RxBool openBirthYearPicker = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_session.userStream);
    _load();
  }

  Future<void> _load() async {
    try {
      layoutStatus.value = CcLayoutStatus.loading;
      final s = await _getSettings();
      settings.value = s;
      appVersion.value = await _deviceInfo.getAppVersion();

      if (getIt.isRegistered<ThemeProvider>()) {
        getIt<ThemeProvider>().toggleTheme(s.isDarkMode);
      }
      layoutStatus.value = CcLayoutStatus.success;
    } catch (e) {
      Catcher2.reportCheckedError(e, StackTrace.current);
      layoutStatus.value = CcLayoutStatus.error;
    }
  }

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  bool get isLoggedIn => user.value != null;

  String get displayName {
    final u = user.value;
    if (u == null) return el.tr(CcLocaleKeys.profile_guest);
    final parts = [
      u.firstName,
      u.lastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    return parts.isNotEmpty ? parts : u.email;
  }

  int get daysToSunday => 7 - DateTime.now().weekday;

  String get weeklyAuditDayName {
    final day = settings.value.weeklyAuditDayIndex + 1;
    final names = el.tr(CcLocaleKeys.common_weekday_names).split('|');
    if (day >= 1 && day <= 7) {
      return names[day - 1];
    }
    return '';
  }

  String currentLanguageName(BuildContext context) {
    return context.locale.languageCode == 'vi'
        ? el.tr(CcLocaleKeys.settings_language_vietnamese)
        : el.tr(CcLocaleKeys.settings_language_english);
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  /// Enables the given category `nameKey`s (mapped to their seed ids) so they
  /// appear checked in the category settings.
  Future<void> enableCategories(List<String> keys) async {
    final idByKey = {for (final c in CategorySeed.categories) c.nameKey: c.id};
    for (final key in keys) {
      final id = idByKey[key];
      if (id != null) await _toggleCategoryEnabled.call(id, true);
    }
  }

  Future<void> toggleReminder(bool value) async {
    final updated = settings.value.copyWith(reminderEnabled: value);
    settings.value = updated;
    await _updateSettings(updated);
  }

  Future<void> setBirthYear(int year) async {
    final updated = settings.value.copyWith(birthYear: year);
    settings.value = updated;
    await _updateSettings(updated);
  }

  Future<void> setWeeklyAuditDay(int dayIndex) async {
    final updated = settings.value.copyWith(weeklyAuditDayIndex: dayIndex);
    settings.value = updated;
    await _updateSettings(updated);
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    final updated = settings.value.copyWith(isDarkMode: isDarkMode);
    settings.value = updated;
    if (getIt.isRegistered<ThemeProvider>()) {
      getIt<ThemeProvider>().toggleTheme(isDarkMode);
    }
    await _updateSettings(updated);
  }

  Future<void> logout(BuildContext context) async {
    await _session.clearSession();
    if (context.mounted) _authCoordinator.navigateToLogin(context);
  }

  void handleHeroBannerTap(BuildContext context) {
    if (!isLoggedIn) {
      _authCoordinator.navigateToLogin(context);
    }
  }

  void openCrashLogViewer(BuildContext context) {
    if (!CrashLogDevOverlay.isViewerEnabled) return;
    final navContext = Catcher2.navigatorKey.currentContext ?? context;
    CcDialogHelper.showModalBottomSheet(navContext, const CrashLogViewerPage());
  }

  Future<void> pickBirthYear(BuildContext context) async {
    final now = DateTime.now();
    final minYear = now.year - 70;
    final maxYear = now.year - 10;
    final current = (settings.value.birthYear ?? now.year - 25).clamp(
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
        await setBirthYear(picked);
        await enableCategories([
          ...CategorySeed.defaultExpenseCategoryKeys[group]!,
          ...CategorySeed.defaultIncomeCategoryKeys[group]!,
        ]);
      }
    }
  }

  Future<void> pickWeeklyAuditDay(BuildContext context) async {
    final current = settings.value.weeklyAuditDayIndex + 1;

    final picked = await WeeklyAuditDayDialog.show(
      context,
      currentDay: current,
    );

    if (picked != null) await setWeeklyAuditDay(picked - 1);
  }

  Future<void> pickLanguage(BuildContext context) async {
    final picked = await LanguageSelectionDialog.show(context);
    if (picked != null && context.mounted) {
      await el.EasyLocalization.of(context)!.setLocale(picked);
    }
  }

  Future<void> navigateToCategorySettings(BuildContext context) async {
    if (settings.value.birthYear == null) {
      await pickBirthYear(context);
      if (settings.value.birthYear == null) return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<bool>(builder: (_) => const CategorySettingsPage()),
    );
  }

  void deleteAccount() {
    // TODO(profile): show confirmation dialog then call delete account use case
  }
}
