import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/auth/domain/repositories/firebase_auth_repository.dart';
import 'package:cc_micro_features/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../category/export_category.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../notification/notification_service.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/profile_settings_entity.dart';
import '../../domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/usecases/update_profile_settings_usecase.dart';
import '../pages/terms_of_service_page.dart';
import '../widgets/birth_year_dialog.dart';
import '../widgets/display_name_dialog.dart';
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
    this.userLevel,
    this._notificationService,
    this._deleteAccount,
  );

  final GetProfileSettingsUseCase _getSettings;
  final UpdateProfileSettingsUseCase _updateSettings;
  final ToggleCategoryEnabledUseCase _toggleCategoryEnabled;
  final SessionContract _session;
  final CcDeviceInfoHelper _deviceInfo;
  final AuthCoordinator _authCoordinator;
  final UserLevelController userLevel;
  final NotificationService _notificationService;
  final DeleteAccountUseCase _deleteAccount;

  final Rxn<CcUserEntity> user = Rxn<CcUserEntity>();
  final Rx<ProfileSettingsEntity> settings = const ProfileSettingsEntity().obs;
  final RxString appVersion = ''.obs;
  final RxBool openBirthYearPicker = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_session.userStream);

    // Sync guideline progress into profile settings to avoid "Split Brain"
    // overwrites when updating other settings (theme, birth year, etc.)
    if (Get.isRegistered<GuidelineController>()) {
      ever(Get.find<GuidelineController>().completedTasks, (
        List<String> tasks,
      ) {
        if (settings.value.completedGuidelineTaskIds != tasks) {
          settings.value = settings.value.copyWith(
            completedGuidelineTaskIds: tasks,
          );
        }
      });
    }

    ever(user, (u) {
      if (u != null) {
      } else {
      }
    });
    _load();
  }

  Future<void> _load() async {
    try {
      layoutStatus.value = CcLayoutStatus.loading;
      final s = await _getSettings();
      settings.value = s;
      appVersion.value = await _deviceInfo.getAppVersion();
      unawaited(userLevel.refresh());

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

    if (parts.isNotEmpty) return parts;
    if (u.email.isNotEmpty) return u.email;
    if (u.phoneNumber != null) return u.phoneNumber!;
    return el.tr(CcLocaleKeys.profile_guest);
  }

  /// Days remaining until the next occurrence of the user's configured
  /// audit weekday (1=Monday..7=Sunday, matching [DateTime.weekday]) — 0
  /// when today is the audit day.
  int get daysToNextAudit {
    final auditWeekday = settings.value.weeklyAuditDayIndex + 1;
    return (auditWeekday - DateTime.now().weekday) % 7;
  }

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
    if (value) {
      final granted = await _notificationService.requestPermission();
      if (!granted) return;
    }
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
    final changed = dayIndex != settings.value.weeklyAuditDayIndex;
    // Changing the audit day invalidates prior reconciliation-streak
    // progress (user-level feature), so re-stamp the anchor whenever the
    // day actually changes.
    final updated = settings.value.copyWith(
      weeklyAuditDayIndex: dayIndex,
      weeklyAuditDayChangedAt: changed ? DateTime.now() : null,
    );
    settings.value = updated;
    await _updateSettings(updated);
  }

  Future<void> setVip(bool value) async {
    final updated = settings.value.copyWith(isVip: value);
    settings.value = updated;
    await _updateSettings(updated);
  }

  /// Debug/QA override — unlocks Investment + Debt/Loan (LV3) instantly,
  /// regardless of actual reconciliation/budget/cash-flow progress.
  Future<void> setForceFullAccess(bool value) async {
    final updated = settings.value.copyWith(forceFullAccess: value);
    settings.value = updated;
    await _updateSettings(updated);
    await userLevel.refresh();
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    final updated = settings.value.copyWith(isDarkMode: isDarkMode);
    settings.value = updated;
    if (getIt.isRegistered<ThemeProvider>()) {
      getIt<ThemeProvider>().toggleTheme(isDarkMode);
    }
    await _updateSettings(updated);
  }

  Future<void> setHeaderFlipped(bool isFlipped) async {
    if (settings.value.isHeaderFlipped == isFlipped) return;
    final updated = settings.value.copyWith(isHeaderFlipped: isFlipped);
    settings.value = updated;
    await _updateSettings(updated);
  }

  Future<void> logout(BuildContext context) async {
    await _session.clearSession();
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

        // Only apply age-based categories if user hasn't customized their categories yet
        if (!settings.value.hasCustomizedCategories) {
          await enableCategories([
            ...CategorySeed.defaultExpenseCategoryKeys[group]!,
            ...CategorySeed.defaultIncomeCategoryKeys[group]!,
            ...CategorySeed.defaultDebtLoanCategoryKeys[group]!,
            ...CategorySeed.defaultInvestmentCategoryKeys[group]!,
            if (CategorySeed.qualifiesForFamilyDefaults(picked))
              ...CategorySeed.familyCategoryKeys,
          ]);
        }

        // Guideline: birth_year completed
        Get.find<GuidelineController>().completeTask('birth_year');
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

  /// Guests have no Firebase account to update — the edit affordance is
  /// hidden for them in [ProfileHeader], but guard here too.
  Future<void> pickDisplayName(BuildContext context) async {
    if (!isLoggedIn) return;

    final u = user.value;
    final fullName = [
      u?.firstName,
      u?.lastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    final name = await DisplayNameDialog.show(context, currentName: fullName);
    if (name == null || name.trim().isEmpty) return;

    final result = await getIt<FirebaseAuthRepository>().updateDisplayName(
      name.trim(),
    );
    result.when(
      // authStateChanges() won't re-emit for a profile-only update, so apply
      // the refreshed entity directly rather than waiting on the stream.
      (updatedUser) {
        user.value = updatedUser;
        if (context.mounted) {
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(CcLocaleKeys.profile_display_name_updated),
          );
        }
      },
      (error) {
        if (context.mounted) {
          CcSnackBarHelper.showErrorSnackBar(
            context: context,
            message: error.message,
          );
        }
      },
    );
  }

  Future<void> pickLanguage(BuildContext context) async {
    final picked = await LanguageSelectionDialog.show(context);
    if (picked != null && context.mounted) {
      await el.EasyLocalization.of(context)!.setLocale(picked);
    }
  }

  /// Handle link account tap - navigate to login page for account linking
  void handleLinkAccountTap(BuildContext context) {
    _authCoordinator.navigateToLogin(context);
  }

  /// Handle avatar tap - navigate to login page
  void handleAvatarTap(BuildContext context) {
    _authCoordinator.navigateToLogin(context);
  }

  /// Handle phone number link tap - navigate to login page
  void handlePhoneLinkTap(BuildContext context) {
    _authCoordinator.navigateToLogin(context);
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

  void navigateToTerms(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TermsOfServicePage()));
  }

  Future<Result<Unit, CcFailure>> deleteAccount() async {
    final result = await _performDeleteAccount();
    if (result.isSuccess()) {
      await _session.clearSession();
    }
    return result;
  }

  Future<Result<Unit, CcFailure>> _performDeleteAccount() async {
    return _deleteAccount.call();
  }
}
