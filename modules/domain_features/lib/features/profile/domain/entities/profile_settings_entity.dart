class ProfileSettingsEntity {
  const ProfileSettingsEntity({
    this.reminderEnabled = false,
    this.weeklyAuditDayIndex = 6,
    this.currencyCode = 'VND',
    this.birthYear,
    this.isDarkMode,
    this.weeklyAuditDayChangedAt,
    this.levelFeatureAnchorAt,
    this.isVip = false,
    this.forceFullAccess = false,
    this.highestUserLevelReached = 1,
    this.firstLaunchAt,
    this.cloudBackupReminderSentAt,
    this.hasViewedEmergencyFundEbook = false,
    this.hasSeenTutorial = false,
    this.isHeaderFlipped = false,
    this.hasCustomizedCategories = false,
    this.completedGuidelineTaskIds = const [],
  });

  final bool reminderEnabled;
  final int weeklyAuditDayIndex;
  final String currencyCode;

  /// Used to pick age-appropriate income suggestions; null until set.
  final int? birthYear;

  /// Theme mode preference: true for dark, false for light, null for system default
  final bool? isDarkMode;

  /// Last time the user changed [weeklyAuditDayIndex]; null if never changed.
  /// User-level reconciliation-streak progress only counts data from this
  /// point forward (changing the audit day resets the streak).
  final DateTime? weeklyAuditDayChangedAt;

  /// Stamped once, the first time settings are read after the user-level
  /// feature shipped. User-level progress only counts data from this point
  /// forward, so pre-existing dev/test data can't grant an instant level.
  final DateTime? levelFeatureAnchorAt;

  /// Manual VIP flag (no real IAP/store billing infra exists yet). Lifts the
  /// free-tier cap on the number of Investment items / Loan records.
  final bool isVip;

  /// Debug/QA override — when true, the user-level feature reports LV3 (all
  /// features unlocked) regardless of actual progress. Independent of [isVip].
  final bool forceFullAccess;

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
  final bool isHeaderFlipped;

  /// Whether the user has manually customized their category settings.
  /// When true, age-based recommendations won't override their choices.
  final bool hasCustomizedCategories;

  /// List of completed guideline task IDs.
  final List<String> completedGuidelineTaskIds;

  ProfileSettingsEntity copyWith({
    bool? reminderEnabled,
    int? weeklyAuditDayIndex,
    String? currencyCode,
    int? birthYear,
    bool? isDarkMode,
    DateTime? weeklyAuditDayChangedAt,
    DateTime? levelFeatureAnchorAt,
    bool? isVip,
    bool? forceFullAccess,
    int? highestUserLevelReached,
    DateTime? firstLaunchAt,
    DateTime? cloudBackupReminderSentAt,
    bool? hasViewedEmergencyFundEbook,
    bool? hasSeenTutorial,
    bool? isHeaderFlipped,
    bool? hasCustomizedCategories,
    List<String>? completedGuidelineTaskIds,
  }) => ProfileSettingsEntity(
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    weeklyAuditDayIndex: weeklyAuditDayIndex ?? this.weeklyAuditDayIndex,
    currencyCode: currencyCode ?? this.currencyCode,
    birthYear: birthYear ?? this.birthYear,
    isDarkMode: isDarkMode ?? this.isDarkMode,
    weeklyAuditDayChangedAt:
        weeklyAuditDayChangedAt ?? this.weeklyAuditDayChangedAt,
    levelFeatureAnchorAt: levelFeatureAnchorAt ?? this.levelFeatureAnchorAt,
    isVip: isVip ?? this.isVip,
    forceFullAccess: forceFullAccess ?? this.forceFullAccess,
    highestUserLevelReached:
        highestUserLevelReached ?? this.highestUserLevelReached,
    firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
    cloudBackupReminderSentAt:
        cloudBackupReminderSentAt ?? this.cloudBackupReminderSentAt,
    hasViewedEmergencyFundEbook:
        hasViewedEmergencyFundEbook ?? this.hasViewedEmergencyFundEbook,
    hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
    isHeaderFlipped: isHeaderFlipped ?? this.isHeaderFlipped,
    hasCustomizedCategories:
        hasCustomizedCategories ?? this.hasCustomizedCategories,
    completedGuidelineTaskIds:
        completedGuidelineTaskIds ?? this.completedGuidelineTaskIds,
  );
}
