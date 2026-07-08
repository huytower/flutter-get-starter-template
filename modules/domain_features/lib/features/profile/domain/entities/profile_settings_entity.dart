class ProfileSettingsEntity {
  const ProfileSettingsEntity({
    this.reminderEnabled = true,
    this.weeklyAuditDayIndex = 6,
    this.currencyCode = 'VND',
  });

  final bool reminderEnabled;
  final int weeklyAuditDayIndex;
  final String currencyCode;

  ProfileSettingsEntity copyWith({
    bool? reminderEnabled,
    int? weeklyAuditDayIndex,
    String? currencyCode,
  }) =>
      ProfileSettingsEntity(
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        weeklyAuditDayIndex: weeklyAuditDayIndex ?? this.weeklyAuditDayIndex,
        currencyCode: currencyCode ?? this.currencyCode,
      );
}
