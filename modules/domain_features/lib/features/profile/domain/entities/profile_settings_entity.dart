import '../../../../core/constant/currency_constants.dart';

class ProfileSettingsEntity {
  const ProfileSettingsEntity({
    this.reminderEnabled = false,
    this.weeklyAuditDayIndex = 6,
    this.currencyCode = CurrencyConstants.defaultCurrencyCode,
    this.currencySelectionSource,
    this.currencyDetectionCountryCode,
    this.birthYear,
    this.hasDarkMode,
    this.weeklyAuditDayChangedAt,
    this.levelFeatureAnchorAt,
    this.hasVipSwitch = false,
    this.hasPaidVip = false,
    this.highestUserLevelReached = 1,
    this.firstLaunchAt,
    this.cloudBackupReminderSentAt,
    this.hasViewedEmergencyFundEbook = false,
    this.hasSeenTutorial = false,
    this.hasHeaderFlipped = false,
    this.hasCustomizedCategories = false,
    this.completedGuidelineTaskIds = const [],
  });

  final bool reminderEnabled;
  final int weeklyAuditDayIndex;
  final String currencyCode;
  final String? currencySelectionSource;
  final String? currencyDetectionCountryCode;

  CurrencySelectionSourceType? get selectionSourceType =>
      CurrencySelectionSourceType.parse(currencySelectionSource);

  /// Used to pick age-appropriate income suggestions; null until set.
  final int? birthYear;

  /// Theme mode preference: true for dark, false for light, null for system default
  final bool? hasDarkMode;

  /// Last time the user changed [weeklyAuditDayIndex]; null if never changed.
  /// User-level reconciliation-streak progress only counts data from this
  /// point forward (changing the audit day resets the streak).
  final DateTime? weeklyAuditDayChangedAt;

  /// Stamped once, the first time settings are read after the user-level
  /// feature shipped. User-level progress only counts data from this point
  /// forward, so pre-existing dev/test data can't grant an instant level.
  final DateTime? levelFeatureAnchorAt;

  /// The free "Unlock Invest, Liability, AI (experiment)" switch in Profile (Hive field 14, synced as
  /// `hasVip`). Temporary: it exists until paid VIP ships, then the switch is
  /// hidden and [hasVipAccess] stops reading it. The stored values are simply
  /// ignored from then on, so no migration is needed.
  final bool hasVipSwitch;

  /// Paid VIP (Hive field 32). Set only by the purchase / entitlement check,
  /// never by a Profile control, and never synced from the device: a client
  /// copy is not proof of payment. Always false until billing exists.
  final bool hasPaidVip;

  /// Whether the user has VIP: the second, independent unlock path next to
  /// the earned level (see `UserLevelStatusEntity`). Also lifts the free-tier
  /// limits on Investment items / Loan records (custom names).
  ///
  /// When paid VIP ships, drop `|| hasVipSwitch` here (or keep it for debug /
  /// QA builds only); nothing else changes.
  bool get hasVipAccess => hasPaidVip || hasVipSwitch;

  /// Highest LV1-3 user level ever computed. Level is monotonic — never
  /// decreases once reached — so the user-level usecase re-applies this
  /// floor on every recomputation even if the live signals later regress.
  final int highestUserLevelReached;

  /// Stamped once, the first time settings are ever read on this install.
  /// Anchors the "2 weeks after install" Cloud-backup reminder.
  final DateTime? firstLaunchAt;

  /// Stamped once the Cloud-backup registration reminder has been shown, so
  /// it only ever fires a single time per install.
  final DateTime? cloudBackupReminderSentAt;

  /// Whether the user has opened the Emergency Fund ebook — one of the two
  /// conditions (with LV2) that unlocks the Emergency Fund wallet type.
  final bool hasViewedEmergencyFundEbook;

  /// Whether the first-launch tutorial has been shown at least once.
  final bool hasSeenTutorial;

  /// Whether the profile header card is currently showing the back surface
  /// (experience chart).
  final bool hasHeaderFlipped;

  /// Whether the user has manually customized their category settings.
  /// When true, age-based recommendations won't override their choices.
  final bool hasCustomizedCategories;

  /// List of completed guideline task IDs.
  final List<String> completedGuidelineTaskIds;

  ProfileSettingsEntity copyWith({
    bool? reminderEnabled,
    int? weeklyAuditDayIndex,
    String? currencyCode,
    String? currencySelectionSource,
    String? currencyDetectionCountryCode,
    int? birthYear,
    bool? hasDarkMode,
    DateTime? weeklyAuditDayChangedAt,
    DateTime? levelFeatureAnchorAt,
    bool? hasVipSwitch,
    bool? hasPaidVip,
    int? highestUserLevelReached,
    DateTime? firstLaunchAt,
    DateTime? cloudBackupReminderSentAt,
    bool? hasViewedEmergencyFundEbook,
    bool? hasSeenTutorial,
    bool? hasHeaderFlipped,
    bool? hasCustomizedCategories,
    List<String>? completedGuidelineTaskIds,
  }) => ProfileSettingsEntity(
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    weeklyAuditDayIndex: weeklyAuditDayIndex ?? this.weeklyAuditDayIndex,
    currencyCode: currencyCode ?? this.currencyCode,
    currencySelectionSource:
        currencySelectionSource ?? this.currencySelectionSource,
    currencyDetectionCountryCode:
        currencyDetectionCountryCode ?? this.currencyDetectionCountryCode,
    birthYear: birthYear ?? this.birthYear,
    hasDarkMode: hasDarkMode ?? this.hasDarkMode,
    weeklyAuditDayChangedAt:
        weeklyAuditDayChangedAt ?? this.weeklyAuditDayChangedAt,
    levelFeatureAnchorAt: levelFeatureAnchorAt ?? this.levelFeatureAnchorAt,
    hasVipSwitch: hasVipSwitch ?? this.hasVipSwitch,
    hasPaidVip: hasPaidVip ?? this.hasPaidVip,
    highestUserLevelReached:
        highestUserLevelReached ?? this.highestUserLevelReached,
    firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
    cloudBackupReminderSentAt:
        cloudBackupReminderSentAt ?? this.cloudBackupReminderSentAt,
    hasViewedEmergencyFundEbook:
        hasViewedEmergencyFundEbook ?? this.hasViewedEmergencyFundEbook,
    hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
    hasHeaderFlipped: hasHeaderFlipped ?? this.hasHeaderFlipped,
    hasCustomizedCategories:
        hasCustomizedCategories ?? this.hasCustomizedCategories,
    completedGuidelineTaskIds:
        completedGuidelineTaskIds ?? this.completedGuidelineTaskIds,
  );
}
