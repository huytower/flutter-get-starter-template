import 'dart:async';

import 'package:app_config/data/converters/domain_user_entity_converter.dart';
import 'package:app_config/domain/entities/auth/domain_user_entity.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

import '../prj_hive_box.dart';

part 'prj_app_storage.g.dart';

///
///[example update]-------------------------------------------------------------
///   PrjAppStorage.instance.accessToken = "token_123";
///   PrjAppStorage.instance.userRole = "admin";
///   PrjAppStorage.instance.save();
///
///[example logger]-------------------------------------------------------------
///   PrjAppStorage.instance.Log();
///

@JsonSerializable()
@HiveType(typeId: PrjHiveBox.APP_STORAGE_TYPE_ID)
class PrjAppStorage extends HiveObject {
  static late PrjAppStorage instance;

  static Future<PrjAppStorage?> register() async {
    Hive.registerAdapter(PrjAppStorageAdapter());
    Box<PrjAppStorage> box = await Hive.openBox<PrjAppStorage>(
      PrjHiveBox.APP_BOX_NAME,
    );
    final model = box.get(PrjHiveBox.keyDefault) ?? PrjAppStorage();

    if (!box.containsKey(PrjHiveBox.keyDefault)) {
      await box.put(PrjHiveBox.keyDefault, model);
    }

    instance = model;
    return model;
  }

  @HiveField(0)
  String? accessToken;

  @HiveField(1)
  String? fcmToken;

  @HiveField(2)
  String? gpsLocation;

  @HiveField(3)
  String? userRole;

  @HiveField(4)
  String? dashboardData;

  @HiveField(5)
  @DomainUserEntityConverter()
  DomainUserEntity? user;

  @HiveField(6)
  bool? reminderEnabled;

  @HiveField(7)
  int? weeklyAuditDayIndex;

  @HiveField(8)
  String? currencyCode;

  @HiveField(9)
  int? birthYear;

  @HiveField(10)
  bool? isDarkMode;

  /// Ids of qltc's guideline onboarding tasks (birth_year, categories,
  /// wallet_balance, ...) already completed by the user.
  ///
  /// Kept at field 11 — this predates the fields below and some installs
  /// already persisted data under this field number, so it must not move.
  @HiveField(11)
  List<String>? completedGuidelineTaskIds;

  /// Timestamp of the last time the user changed [weeklyAuditDayIndex].
  /// Used to reset user-level streak progress when the audit day changes.
  @HiveField(12)
  DateTime? weeklyAuditDayChangedAt;

  /// Stamped once, the first time the user-level feature reads settings.
  /// User-level progress (reconciliation streaks etc.) only counts data
  /// from this point forward, so pre-existing dev/test data can't grant
  /// an instant level.
  @HiveField(13)
  DateTime? levelFeatureAnchorAt;

  /// Manual VIP flag (no real IAP/store billing infra exists yet).
  @HiveField(14)
  bool? isVip;

  /// Highest LV1-3 user level ever computed. Level is monotonic — never
  /// decreases once reached — so this floor is re-applied on every
  /// recomputation even if the live signals (streak/budgets/cash-flow)
  /// later regress.
  @HiveField(16)
  int? highestUserLevelReached;

  /// Stamped once, the first time settings are ever read on this install.
  /// Anchors the "2 weeks after install" Cloud-backup reminder.
  @HiveField(17)
  DateTime? firstLaunchAt;

  /// Stamped once the Cloud-backup registration reminder has been shown, so
  /// it only ever fires a single time per install.
  @HiveField(18)
  DateTime? cloudBackupReminderSentAt;

  /// Stamped once the user has opened the Emergency Fund ebook — one of the
  /// two conditions (with LV2) that unlocks the Emergency Fund wallet type.
  @HiveField(19)
  bool? hasViewedEmergencyFundEbook;

  /// Stamped once the first-launch tutorial has been shown (or replayed —
  /// re-running it via "Xem hướng dẫn lại" doesn't unset this).
  @HiveField(20)
  bool? hasSeenTutorial;

  /// Whether the profile header card is currently showing the back surface
  /// (experience chart). Persisted to last through app restarts.
  @HiveField(21)
  bool? isProfileHeaderFlipped;

  /// Whether the user has manually customized their category settings.
  /// When true, age-based recommendations won't override their choices.
  @HiveField(22)
  bool? hasCustomizedCategories;

  /// Whether the user has interacted with the card-stack tab bar in the
  /// Transaction page. Used to hide the initial "swipe/tap" hint.
  @HiveField(23)
  bool? hasInteractedWithTransactionCardStack;

  /// Firebase UID that owns the financial Hive cache on this device.
  @HiveField(24)
  String? financialDataOwnerId;

  /// Source of currency selection ('detected', 'user_selected', 'migrated').
  @HiveField(25)
  String? currencySelectionSource;

  /// Country code detected during initial currency suggestion.
  @HiveField(26)
  String? currencyDetectionCountryCode;

  /// Version of the financial schema migration runner.
  @HiveField(27)
  int? financialSchemaVersion;

  /// Whether the first "sign in to back up your data" reminder was shown to
  /// the current guest session.
  @HiveField(28)
  bool? hasShownGuestLoginFirstReminder;

  /// Whether the guest dismissed the final sign-in warning, so no more
  /// reminders are shown in this session.
  @HiveField(29)
  bool? hasDismissedGuestLoginFinalWarning;

  @HiveField(30)
  String? guestLoginPromptSessionUid;

  PrjAppStorage({
    this.accessToken,
    this.fcmToken,
    this.gpsLocation,
    this.userRole,
    this.dashboardData,
    this.user,
    this.reminderEnabled,
    this.weeklyAuditDayIndex,
    this.currencyCode,
    this.birthYear,
    this.isDarkMode,
    this.completedGuidelineTaskIds,
    this.weeklyAuditDayChangedAt,
    this.levelFeatureAnchorAt,
    this.isVip,
    this.highestUserLevelReached,
    this.firstLaunchAt,
    this.cloudBackupReminderSentAt,
    this.hasViewedEmergencyFundEbook,
    this.hasSeenTutorial,
    this.isProfileHeaderFlipped,
    this.hasCustomizedCategories,
    this.hasInteractedWithTransactionCardStack,
    this.financialDataOwnerId,
    this.currencySelectionSource,
    this.currencyDetectionCountryCode,
    this.financialSchemaVersion,
    this.hasShownGuestLoginFirstReminder,
    this.hasDismissedGuestLoginFinalWarning,
    this.guestLoginPromptSessionUid,
  });
}
