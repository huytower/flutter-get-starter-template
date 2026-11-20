import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../category/export_category.dart';
import '../../../firestore/financial_data_sync_service.dart';
import '../../domain/entities/profile_settings_entity.dart';
import '../../user_level/presentation/get_x/user_level_controller.dart';
import '../pages/terms_of_service_page.dart';
import '../widgets/birth_year_sheet.dart';
import '../widgets/currency_selection_sheet.dart';
import '../widgets/display_name_sheet.dart';
import '../widgets/language_selection_sheet.dart';
import '../widgets/weekly_audit_day_sheet.dart';
import '../actions/ai_consent_handler.dart';
import '../actions/profile_account_actions.dart';
import '../actions/profile_onboarding_actions.dart';
import '../actions/profile_settings_actions.dart';

@lazySingleton
class ProfileController extends CcGetController {
  ProfileController(
    this._settingsActions,
    this._account,
    this._onboarding,
    this._aiConsent,
    this.userLevel,
  );

  final ProfileSettingsActions _settingsActions;
  final ProfileAccountActions _account;
  final ProfileOnboardingActions _onboarding;
  final AiConsentHandler _aiConsent;
  final UserLevelController userLevel;

  final Rxn<CcUserEntity> user = Rxn<CcUserEntity>();
  final Rx<ProfileSettingsEntity> settings = const ProfileSettingsEntity().obs;
  final RxString appVersion = ''.obs;
  final RxBool openBirthYearPicker = false.obs;

  /// Whether the user allowed sharing data with Gemini (Google). Off until the
  /// user agrees in the AI consent sheet.
  final RxBool aiSharingEnabled = false.obs;

  Future<void> _loadAiSharing() async {
    aiSharingEnabled.value = await _aiConsent.isEnabled();
  }

  /// Turning it on shows the consent sheet; turning it off withdraws consent.
  Future<void> toggleAiSharing(BuildContext context, bool value) async {
    if (!value) {
      await _aiConsent.withdraw();
      aiSharingEnabled.value = false;
      return;
    }
    aiSharingEnabled.value = await _aiConsent.request(context);
  }

  /// "Unlock all features" also unlocks the AI features, so enabling it asks
  /// for the AI data-sharing consent first. Either answer still unlocks the
  /// features; only "Allow" turns on sharing.
  Future<void> toggleFullAccess(BuildContext context, bool value) async {
    if (value) {
      aiSharingEnabled.value = await _aiConsent.request(context);
    }
    await setVip(value);
  }

  // --- Sign-in reminder (shown to users with no linked email/phone) ---
  static const String _signInReminderDismissedKey =
      'profile_sign_in_reminder_dismissed';

  /// Once dismissed the reminder never comes back (across app launches and page
  /// resumes). Starts hidden so it never flashes before the stored choice loads.
  final RxBool signInReminderDismissed = true.obs;

  /// True when the account has neither an email nor a phone number linked.
  bool get needsSignIn {
    final u = user.value;
    return u == null || (u.email.isEmpty && (u.phoneNumber ?? '').isEmpty);
  }

  bool get showSignInReminder => needsSignIn && !signInReminderDismissed.value;

  Future<void> _loadSignInReminder() async {
    final prefs = await SharedPreferences.getInstance();
    signInReminderDismissed.value =
        prefs.getBool(_signInReminderDismissedKey) ?? false;
  }

  Future<void> dismissSignInReminder() async {
    signInReminderDismissed.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signInReminderDismissedKey, true);
  }

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_account.userStream);
    unawaited(_loadAiSharing());

    // Sync guideline progress into profile settings to avoid "Split Brain"
    // overwrites when updating other settings (theme, birth year, etc.)
    _onboarding.onGuidelineProgress((List<String> tasks) {
      if (settings.value.completedGuidelineTaskIds != tasks) {
        settings.value = settings.value.copyWith(
          completedGuidelineTaskIds: tasks,
        );
      }
    });

    ever(user, (u) {
      if (u != null) {
      } else {}
    });
    ever(CurrencyConstants.onCurrencyChanged, (_) => _syncStoredCurrency());
    _load();
    unawaited(_loadSignInReminder());
  }

  Future<void> _syncStoredCurrency() async {
    final stored = await _settingsActions.load();
    if (stored.currencyCode == settings.value.currencyCode) return;
    settings.value = settings.value.copyWith(
      currencyCode: stored.currencyCode,
      currencySelectionSource: stored.currencySelectionSource,
      currencyDetectionCountryCode: stored.currencyDetectionCountryCode,
    );
  }

  Future<void> _load() async {
    try {
      layoutStatus.value = CcLayoutStatus.loading;
      settings.value = await _settingsActions.load();
      appVersion.value = await _settingsActions.appVersion();
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
    final languageCode = context.locale.languageCode;
    switch (languageCode) {
      case 'vi':
        return el.tr(CcLocaleKeys.settings_language_vietnamese);
      case 'ko':
        return el.tr(CcLocaleKeys.settings_language_korean);
      case 'ja':
        return el.tr(CcLocaleKeys.settings_language_japanese);
      case 'zh':
        return el.tr(CcLocaleKeys.settings_language_chinese);
      case 'en':
      default:
        return el.tr(CcLocaleKeys.settings_language_english);
    }
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  Future<void> toggleReminder(bool value) async {
    if (value) {
      final granted = await _settingsActions.requestReminderPermission();
      if (!granted) return;
    }
    final updated = settings.value.copyWith(reminderEnabled: value);
    settings.value = updated;
    await _settingsActions.save(updated);
  }

  Future<void> setBirthYear(int year) async {
    final updated = settings.value.copyWith(birthYear: year);
    settings.value = updated;
    await _settingsActions.save(updated);
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
    await _settingsActions.save(updated);
  }

  Future<void> setVip(bool value) async {
    final updated = settings.value.copyWith(isVip: value);
    settings.value = updated;
    await _settingsActions.save(updated);

    if (value) await _onboarding.enableFullAccessCategories();

    // Refresh user level status so gated sections (Investment/Liability)
    // appear immediately across the app.
    await userLevel.refresh();

    // If CategorySettingsController is active, reload it to pick up the
    // newly-enabled categories and updated user level.
    _onboarding.refreshCategorySettings();
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    final updated = settings.value.copyWith(isDarkMode: isDarkMode);
    settings.value = updated;
    _settingsActions.applyTheme(isDarkMode: isDarkMode);
    await _settingsActions.save(updated);
  }

  Future<void> setHeaderFlipped(bool isFlipped) async {
    if (settings.value.isHeaderFlipped == isFlipped) return;
    final updated = settings.value.copyWith(isHeaderFlipped: isFlipped);
    settings.value = updated;
    await _settingsActions.save(updated);
  }

  /// Guards sign-out so the user can never leave behind unsynced financial
  /// records. Returns the reason it was refused, or null on success.
  Future<LogoutResult?> logout(BuildContext context) => _account.logout();

  /// Whether the logout button should be interactive.
  bool get canLogout => _account.canLogout;

  /// Null when logout is allowed, otherwise why it is blocked.
  LogoutBlock? get logoutBlock => _account.logoutBlock;

  void handleHeroBannerTap(BuildContext context) {
    if (!isLoggedIn) {
      _account.openLogin(context);
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

    final picked = await BirthYearSheet.show(
      context,
      currentYear: current,
      minYear: minYear,
      maxYear: maxYear,
    );

    if (picked != null && CategorySeed.ageGroup(picked) != null) {
      await setBirthYear(picked);
      await _onboarding.applyBirthYear(
        picked,
        hasCustomizedCategories: settings.value.hasCustomizedCategories,
      );
    }
  }

  Future<void> pickWeeklyAuditDay(BuildContext context) async {
    final current = settings.value.weeklyAuditDayIndex + 1;

    final picked = await WeeklyAuditDaySheet.show(context, currentDay: current);

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

    final name = await DisplayNameSheet.show(context, currentName: fullName);
    if (name == null || name.trim().isEmpty) return;

    final result = await _account.updateDisplayName(name.trim());
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
    final picked = await LanguageSelectionSheet.show(context);
    if (picked != null && context.mounted) {
      await el.EasyLocalization.of(context)!.setLocale(picked);
      CategorySettingsController.onCategoriesChanged.value++;
    }
  }

  Future<void> pickCurrency(BuildContext context) async {
    final picked = await CurrencySelectionSheet.show(
      context,
      settings.value.currencyCode,
    );
    if (picked != null && picked != settings.value.currencyCode) {
      final updated = settings.value.copyWith(
        currencyCode: picked,
        currencySelectionSource: CurrencySelectionSources.userSelected,
      );
      settings.value = updated;
      await _settingsActions.save(updated);
      await _load();
      CurrencyConstants.onCurrencyChanged.value++;
    }
  }

  /// Handle link account tap - navigate to login page for account linking
  void handleLinkAccountTap(BuildContext context) {
    _account.openLogin(context);
  }

  /// Handle avatar tap - navigate to login page only if not logged in
  void handleAvatarTap(BuildContext context) {
    if (!isLoggedIn) {
      _account.openLogin(context);
    }
  }

  /// Handle phone number link tap - navigate to login page
  void handlePhoneLinkTap(BuildContext context) {
    _account.openLogin(context);
  }

  Future<void> navigateToCategorySettings(BuildContext context) async {
    if (settings.value.birthYear == null) {
      await pickBirthYear(context);
      if (settings.value.birthYear == null) return;
    }
    if (!context.mounted) return;

    _onboarding.completeCategoriesTask();

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
    layoutStatus.value = CcLayoutStatus.loading;
    try {
      return await _account.deleteAccount();
    } finally {
      layoutStatus.value = CcLayoutStatus.success;
    }
  }
}
