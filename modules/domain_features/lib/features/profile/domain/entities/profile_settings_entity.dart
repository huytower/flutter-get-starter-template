class ProfileSettingsEntity {
  const ProfileSettingsEntity({
    this.reminderEnabled = true,
    this.weeklyAuditDayIndex = 6,
    this.currencyCode = 'VND',
    this.birthYear,
  });

  final bool reminderEnabled;
  final int weeklyAuditDayIndex;
  final String currencyCode;

  /// Used to pick age-appropriate income suggestions; null until set.
  final int? birthYear;

  ProfileSettingsEntity copyWith({
    bool? reminderEnabled,
    int? weeklyAuditDayIndex,
    String? currencyCode,
    int? birthYear,
  }) =>
      ProfileSettingsEntity(
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        weeklyAuditDayIndex: weeklyAuditDayIndex ?? this.weeklyAuditDayIndex,
        currencyCode: currencyCode ?? this.currencyCode,
        birthYear: birthYear ?? this.birthYear,
      );
}
