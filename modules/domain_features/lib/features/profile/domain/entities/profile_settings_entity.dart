class ProfileSettingsEntity {
  const ProfileSettingsEntity({
    this.reminderEnabled = true,
    this.weeklyAuditDayIndex = 6,
    this.currencyCode = 'VND',
    this.birthYear,
    this.isDarkMode = false,
  });

  final bool reminderEnabled;
  final int weeklyAuditDayIndex;
  final String currencyCode;

  /// Used to pick age-appropriate income suggestions; null until set.
  final int? birthYear;

  /// Theme mode preference: true for dark, false for light
  final bool isDarkMode;

  ProfileSettingsEntity copyWith({
    bool? reminderEnabled,
    int? weeklyAuditDayIndex,
    String? currencyCode,
    int? birthYear,
    bool? isDarkMode,
  }) => ProfileSettingsEntity(
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    weeklyAuditDayIndex: weeklyAuditDayIndex ?? this.weeklyAuditDayIndex,
    currencyCode: currencyCode ?? this.currencyCode,
    birthYear: birthYear ?? this.birthYear,
    isDarkMode: isDarkMode ?? this.isDarkMode,
  );
}
