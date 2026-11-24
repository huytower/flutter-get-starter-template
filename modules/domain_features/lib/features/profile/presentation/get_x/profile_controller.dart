import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/contracts/guideline_provider.dart';
import '../../../../core/get_x/prj_get_controller.dart';
import '../../../category/export_category.dart';
import '../../../firestore/financial_data_sync_service.dart';
import '../../domain/entities/profile_settings_entity.dart';
import '../../user_level/presentation/get_x/user_level_controller.dart';
import '../actions/profile_account_actions.dart';
import '../actions/profile_app_actions.dart';
import '../actions/profile_onboarding_actions.dart';
import '../actions/profile_settings_actions.dart';
import '../helper/profile_display_text.dart';
import '../helper/profile_routes.dart';
import '../helper/profile_sheets.dart';

@lazySingleton
class ProfileController extends PrjGetController {
  ProfileController(
    this._settingsActions,
    this._account,
    this._onboarding,
    this._app,
    this.userLevel,
  );

  final ProfileSettingsActions _settingsActions;
  final ProfileAccountActions _account;
  final ProfileOnboardingActions _onboarding;
  final ProfileAppActions _app;
  final UserLevelController userLevel;

  /// For the guideline badges on the settings tiles.
  GuidelineProvider get guideline => _onboarding.guideline;

  /// For the sync indicator on the profile card.
  FinancialDataSyncService get syncService => _account.syncService;

  /// For the rating sheet's feedback section.
  CcFeedbackReporter get feedbackReporter => _app.feedbackReporter;

  final Rxn<CcUserEntity> user = Rxn<CcUserEntity>();
  final Rx<ProfileSettingsEntity> settings = const ProfileSettingsEntity().obs;
  final RxString appVersion = ''.obs;
  final RxBool openBirthYearPicker = false.obs;

  /// Whether the user allowed sharing data with Gemini (Google). Off until the
  /// user agrees in the AI consent sheet.
  final RxBool aiSharingEnabled = false.obs;

  Future<void> _loadAiSharing() async {
    aiSharingEnabled.value = await _app.isAiSharingEnabled();
  }

  /// Turning it on shows the consent sheet; turning it off withdraws consent.
  Future<void> toggleAiSharing(BuildContext context, bool value) async {
    if (!value) {
      await _app.withdrawAiConsent();
      aiSharingEnabled.value = false;
      return;
    }
    aiSharingEnabled.value = await _app.requestAiConsent(context);
  }

  /// "Unlock all features" also unlocks the AI features, so enabling it asks
  /// for the AI data-sharing consent first. Either answer still unlocks the
  /// features; only "Allow" turns on sharing.
  Future<void> toggleFullAccess(BuildContext context, bool value) async {
    if (value) {
      aiSharingEnabled.value = await _app.requestAiConsent(context);
    }
    await setVip(value);
  }

  // --- Sign-in reminder (shown to users with no linked email/phone) ---

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
    signInReminderDismissed.value = await _settingsActions
        .isSignInReminderDismissed();
  }

  Future<void> dismissSignInReminder() async {
    signInReminderDismissed.value = true;
    await _settingsActions.dismissSignInReminder();
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

  /// Shows [updated] immediately, then persists it.
  Future<void> _save(ProfileSettingsEntity updated) async {
    settings.value = updated;
    await _settingsActions.save(updated);
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

  bool get hasLoggedIn => user.value != null;

  /// Deleting an Apple-linked account asks Apple to confirm first.
  bool get hasAppleSignIn =>
      user.value?.linkedProviderIds.contains('apple.com') ?? false;

  /// How the signed-in account is identified to the user: email, else phone,
  /// else name. Null for an account with none of them.
  String? get accountLabel {
    final u = user.value;
    if (u == null) return null;
    if (u.email.isNotEmpty) return u.email;
    final phone = u.phoneNumber ?? '';
    if (phone.isNotEmpty) return phone;
    final name = ProfileDisplayText.fullName(u);
    return name.isEmpty ? null : name;
  }

  String get displayName => ProfileDisplayText.displayName(user.value);

  /// Days until the configured audit weekday; 0 when today is the audit day.
  int get daysToNextAudit => ProfileDisplayText.daysToNextAudit(
    settings.value.weeklyAuditDayIndex,
    DateTime.now(),
  );

  String get weeklyAuditDayName =>
      ProfileDisplayText.weeklyAuditDayName(settings.value.weeklyAuditDayIndex);

  String currentLanguageName(BuildContext context) =>
      ProfileDisplayText.languageName(context.locale.languageCode);

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  Future<void> toggleReminder(bool value) async {
    if (value) {
      final granted = await _settingsActions.requestReminderPermission();
      if (!granted) return;
    }
    await _save(settings.value.copyWith(reminderEnabled: value));
  }

  Future<void> setBirthYear(int year) async {
    await _save(settings.value.copyWith(birthYear: year));
  }

  Future<void> setWeeklyAuditDay(int dayIndex) async {
    final changed = dayIndex != settings.value.weeklyAuditDayIndex;
    // Changing the audit day invalidates prior reconciliation-streak
    // progress (user-level feature), so re-stamp the anchor whenever the
    // day actually changes.
    await _save(
      settings.value.copyWith(
        weeklyAuditDayIndex: dayIndex,
        weeklyAuditDayChangedAt: changed ? DateTime.now() : null,
      ),
    );
  }

  Future<void> setVip(bool value) async {
    await _save(settings.value.copyWith(hasVip: value));

    if (value) await _onboarding.enableFullAccessCategories();

    // Refresh user level status so gated sections (Investment/Liability)
    // appear immediately across the app.
    await userLevel.refresh();

    // If CategorySettingsController is active, reload it to pick up the
    // newly-enabled categories and updated user level.
    _onboarding.refreshCategorySettings();
  }

  Future<void> setThemeMode(bool hasDarkMode) async {
    _settingsActions.applyTheme(hasDarkMode: hasDarkMode);
    await _save(settings.value.copyWith(hasDarkMode: hasDarkMode));
  }

  Future<void> setHeaderFlipped(bool hasFlipped) async {
    if (settings.value.hasHeaderFlipped == hasFlipped) return;
    await _save(settings.value.copyWith(hasHeaderFlipped: hasFlipped));
  }

  /// Guards sign-out so the user can never leave behind unsynced financial
  /// records. Returns the reason it was refused, or null on success.
  Future<LogoutResult?> logout(BuildContext context) => _account.logout();

  /// Whether the logout button should be interactive.
  bool get canLogout => _account.canLogout;

  /// Null when logout is allowed, otherwise why it is blocked.
  LogoutBlock? get logoutBlock => _account.logoutBlock;

  void handleHeroBannerTap(BuildContext context) {
    if (!hasLoggedIn) _account.openLogin(context);
  }

  void openCrashLogViewer(BuildContext context) =>
      ProfileRoutes.crashLogViewer(context);

  Future<void> pickBirthYear(BuildContext context) async {
    final picked = await ProfileSheets.birthYear(
      context,
      settings.value.birthYear,
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
    final picked = await ProfileSheets.weeklyAuditDay(
      context,
      settings.value.weeklyAuditDayIndex,
    );
    if (picked != null) await setWeeklyAuditDay(picked);
  }

  /// Guests have no Firebase account to update — the edit affordance is
  /// hidden for them in [ProfileHeader], but guard here too.
  Future<void> pickDisplayName(BuildContext context) async {
    if (!hasLoggedIn) return;

    final name = await ProfileSheets.displayName(
      context,
      ProfileDisplayText.fullName(user.value),
    );
    if (name == null) return;

    final result = await _account.updateDisplayName(name);
    result.when(
      // authStateChanges() won't re-emit for a profile-only update, so apply
      // the refreshed entity directly rather than waiting on the stream.
      (updatedUser) {
        user.value = updatedUser;
        if (context.mounted) {
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(PrjLocaleKeys.profile_display_name_updated),
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

  Future<void> pickLanguage(BuildContext context) =>
      ProfileSheets.language(context);

  Future<void> pickCurrency(BuildContext context) async {
    final picked = await ProfileSheets.currency(
      context,
      settings.value.currencyCode,
    );
    final current = settings.value.currencyCode;
    if (picked != null && picked != current) {
      // The whole book is converted into the new currency (see
      // BookCurrencyAligner), so ask first.
      if (!context.mounted) return;
      final confirmed = await CcDialogHelper.showMessageBottomSheet(
        context: context,
        title: el.tr(
          PrjLocaleKeys.profile_currency_convert_title,
          namedArgs: {'to': picked},
        ),
        content: el.tr(
          PrjLocaleKeys.profile_currency_convert_message,
          namedArgs: {'from': current, 'to': picked},
        ),
      );
      if (confirmed != true) return;
      await _save(
        settings.value.copyWith(
          currencyCode: picked,
          currencySelectionSource: CurrencySelectionSources.userSelected,
        ),
      );
      await _load();
      CurrencyConstants.onCurrencyChanged.value++;
    }
  }

  /// Linking an account or phone opens the login screen.
  void handleLinkAccountTap(BuildContext context) =>
      _account.openLogin(context);

  void handlePhoneLinkTap(BuildContext context) => _account.openLogin(context);

  /// Only guests are sent to login from the avatar.
  void handleAvatarTap(BuildContext context) {
    if (!hasLoggedIn) _account.openLogin(context);
  }

  Future<void> navigateToCategorySettings(BuildContext context) async {
    if (settings.value.birthYear == null) {
      await pickBirthYear(context);
      if (settings.value.birthYear == null) return;
    }
    if (!context.mounted) return;

    _onboarding.completeCategoriesTask();

    ProfileRoutes.categorySettings(context);
  }

  void navigateToTerms(BuildContext context) => ProfileRoutes.terms(context);

  Future<Result<Unit, CcFailure>> deleteAccount() async {
    layoutStatus.value = CcLayoutStatus.loading;
    try {
      return await _account.deleteAccount();
    } finally {
      layoutStatus.value = CcLayoutStatus.success;
    }
  }
}
