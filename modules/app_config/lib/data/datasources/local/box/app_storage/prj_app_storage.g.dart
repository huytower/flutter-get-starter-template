// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prj_app_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrjAppStorageAdapter extends TypeAdapter<PrjAppStorage> {
  @override
  final typeId = 2;

  @override
  PrjAppStorage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrjAppStorage(
      accessToken: fields[0] as String?,
      fcmToken: fields[1] as String?,
      gpsLocation: fields[2] as String?,
      userRole: fields[3] as String?,
      dashboardData: fields[4] as String?,
      user: fields[5] as DomainUserEntity?,
      reminderEnabled: fields[6] as bool?,
      weeklyAuditDayIndex: (fields[7] as num?)?.toInt(),
      currencyCode: fields[8] as String?,
      birthYear: (fields[9] as num?)?.toInt(),
      hasDarkMode: fields[10] as bool?,
      completedGuidelineTaskIds: (fields[11] as List?)?.cast<String>(),
      weeklyAuditDayChangedAt: fields[12] as DateTime?,
      levelFeatureAnchorAt: fields[13] as DateTime?,
      hasVip: fields[14] as bool?,
      highestUserLevelReached: (fields[16] as num?)?.toInt(),
      firstLaunchAt: fields[17] as DateTime?,
      cloudBackupReminderSentAt: fields[18] as DateTime?,
      hasViewedEmergencyFundEbook: fields[19] as bool?,
      hasSeenTutorial: fields[20] as bool?,
      hasProfileHeaderFlipped: fields[21] as bool?,
      hasCustomizedCategories: fields[22] as bool?,
      hasInteractedWithTransactionCardStack: fields[23] as bool?,
      financialDataOwnerId: fields[24] as String?,
      currencySelectionSource: fields[25] as String?,
      currencyDetectionCountryCode: fields[26] as String?,
      financialSchemaVersion: (fields[27] as num?)?.toInt(),
      hasShownGuestLoginFirstReminder: fields[28] as bool?,
      hasDismissedGuestLoginFinalWarning: fields[29] as bool?,
      guestLoginPromptSessionUid: fields[30] as String?,
      accountSettingsSyncedJson: fields[31] as String?,
      hasPaidVip: fields[32] as bool?,
      pendingCloudDeletes: (fields[33] as List?)?.cast<String>(),
      lastEntryWalletId: fields[34] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PrjAppStorage obj) {
    writer
      ..writeByte(34)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.fcmToken)
      ..writeByte(2)
      ..write(obj.gpsLocation)
      ..writeByte(3)
      ..write(obj.userRole)
      ..writeByte(4)
      ..write(obj.dashboardData)
      ..writeByte(5)
      ..write(obj.user)
      ..writeByte(6)
      ..write(obj.reminderEnabled)
      ..writeByte(7)
      ..write(obj.weeklyAuditDayIndex)
      ..writeByte(8)
      ..write(obj.currencyCode)
      ..writeByte(9)
      ..write(obj.birthYear)
      ..writeByte(10)
      ..write(obj.hasDarkMode)
      ..writeByte(11)
      ..write(obj.completedGuidelineTaskIds)
      ..writeByte(12)
      ..write(obj.weeklyAuditDayChangedAt)
      ..writeByte(13)
      ..write(obj.levelFeatureAnchorAt)
      ..writeByte(14)
      ..write(obj.hasVip)
      ..writeByte(16)
      ..write(obj.highestUserLevelReached)
      ..writeByte(17)
      ..write(obj.firstLaunchAt)
      ..writeByte(18)
      ..write(obj.cloudBackupReminderSentAt)
      ..writeByte(19)
      ..write(obj.hasViewedEmergencyFundEbook)
      ..writeByte(20)
      ..write(obj.hasSeenTutorial)
      ..writeByte(21)
      ..write(obj.hasProfileHeaderFlipped)
      ..writeByte(22)
      ..write(obj.hasCustomizedCategories)
      ..writeByte(23)
      ..write(obj.hasInteractedWithTransactionCardStack)
      ..writeByte(24)
      ..write(obj.financialDataOwnerId)
      ..writeByte(25)
      ..write(obj.currencySelectionSource)
      ..writeByte(26)
      ..write(obj.currencyDetectionCountryCode)
      ..writeByte(27)
      ..write(obj.financialSchemaVersion)
      ..writeByte(28)
      ..write(obj.hasShownGuestLoginFirstReminder)
      ..writeByte(29)
      ..write(obj.hasDismissedGuestLoginFinalWarning)
      ..writeByte(30)
      ..write(obj.guestLoginPromptSessionUid)
      ..writeByte(31)
      ..write(obj.accountSettingsSyncedJson)
      ..writeByte(32)
      ..write(obj.hasPaidVip)
      ..writeByte(33)
      ..write(obj.pendingCloudDeletes)
      ..writeByte(34)
      ..write(obj.lastEntryWalletId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrjAppStorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrjAppStorage _$PrjAppStorageFromJson(
  Map<String, dynamic> json,
) => PrjAppStorage(
  accessToken: json['accessToken'] as String?,
  fcmToken: json['fcmToken'] as String?,
  gpsLocation: json['gpsLocation'] as String?,
  userRole: json['userRole'] as String?,
  dashboardData: json['dashboardData'] as String?,
  user: const DomainUserEntityConverter().fromJson(
    json['user'] as Map<String, dynamic>?,
  ),
  reminderEnabled: json['reminderEnabled'] as bool?,
  weeklyAuditDayIndex: (json['weeklyAuditDayIndex'] as num?)?.toInt(),
  currencyCode: json['currencyCode'] as String?,
  birthYear: (json['birthYear'] as num?)?.toInt(),
  hasDarkMode: json['hasDarkMode'] as bool?,
  completedGuidelineTaskIds:
      (json['completedGuidelineTaskIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  weeklyAuditDayChangedAt: json['weeklyAuditDayChangedAt'] == null
      ? null
      : DateTime.parse(json['weeklyAuditDayChangedAt'] as String),
  levelFeatureAnchorAt: json['levelFeatureAnchorAt'] == null
      ? null
      : DateTime.parse(json['levelFeatureAnchorAt'] as String),
  hasVip: json['hasVip'] as bool?,
  highestUserLevelReached: (json['highestUserLevelReached'] as num?)?.toInt(),
  firstLaunchAt: json['firstLaunchAt'] == null
      ? null
      : DateTime.parse(json['firstLaunchAt'] as String),
  cloudBackupReminderSentAt: json['cloudBackupReminderSentAt'] == null
      ? null
      : DateTime.parse(json['cloudBackupReminderSentAt'] as String),
  hasViewedEmergencyFundEbook: json['hasViewedEmergencyFundEbook'] as bool?,
  hasSeenTutorial: json['hasSeenTutorial'] as bool?,
  hasProfileHeaderFlipped: json['hasProfileHeaderFlipped'] as bool?,
  hasCustomizedCategories: json['hasCustomizedCategories'] as bool?,
  hasInteractedWithTransactionCardStack:
      json['hasInteractedWithTransactionCardStack'] as bool?,
  financialDataOwnerId: json['financialDataOwnerId'] as String?,
  currencySelectionSource: json['currencySelectionSource'] as String?,
  currencyDetectionCountryCode: json['currencyDetectionCountryCode'] as String?,
  financialSchemaVersion: (json['financialSchemaVersion'] as num?)?.toInt(),
  hasShownGuestLoginFirstReminder:
      json['hasShownGuestLoginFirstReminder'] as bool?,
  hasDismissedGuestLoginFinalWarning:
      json['hasDismissedGuestLoginFinalWarning'] as bool?,
  guestLoginPromptSessionUid: json['guestLoginPromptSessionUid'] as String?,
  accountSettingsSyncedJson: json['accountSettingsSyncedJson'] as String?,
  hasPaidVip: json['hasPaidVip'] as bool?,
  pendingCloudDeletes: (json['pendingCloudDeletes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  lastEntryWalletId: json['lastEntryWalletId'] as String?,
);

Map<String, dynamic> _$PrjAppStorageToJson(
  PrjAppStorage instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'fcmToken': instance.fcmToken,
  'gpsLocation': instance.gpsLocation,
  'userRole': instance.userRole,
  'dashboardData': instance.dashboardData,
  'user': const DomainUserEntityConverter().toJson(instance.user),
  'reminderEnabled': instance.reminderEnabled,
  'weeklyAuditDayIndex': instance.weeklyAuditDayIndex,
  'currencyCode': instance.currencyCode,
  'birthYear': instance.birthYear,
  'hasDarkMode': instance.hasDarkMode,
  'completedGuidelineTaskIds': instance.completedGuidelineTaskIds,
  'weeklyAuditDayChangedAt': instance.weeklyAuditDayChangedAt
      ?.toIso8601String(),
  'levelFeatureAnchorAt': instance.levelFeatureAnchorAt?.toIso8601String(),
  'hasVip': instance.hasVip,
  'highestUserLevelReached': instance.highestUserLevelReached,
  'firstLaunchAt': instance.firstLaunchAt?.toIso8601String(),
  'cloudBackupReminderSentAt': instance.cloudBackupReminderSentAt
      ?.toIso8601String(),
  'hasViewedEmergencyFundEbook': instance.hasViewedEmergencyFundEbook,
  'hasSeenTutorial': instance.hasSeenTutorial,
  'hasProfileHeaderFlipped': instance.hasProfileHeaderFlipped,
  'hasCustomizedCategories': instance.hasCustomizedCategories,
  'hasInteractedWithTransactionCardStack':
      instance.hasInteractedWithTransactionCardStack,
  'financialDataOwnerId': instance.financialDataOwnerId,
  'currencySelectionSource': instance.currencySelectionSource,
  'currencyDetectionCountryCode': instance.currencyDetectionCountryCode,
  'financialSchemaVersion': instance.financialSchemaVersion,
  'hasShownGuestLoginFirstReminder': instance.hasShownGuestLoginFirstReminder,
  'hasDismissedGuestLoginFinalWarning':
      instance.hasDismissedGuestLoginFinalWarning,
  'guestLoginPromptSessionUid': instance.guestLoginPromptSessionUid,
  'accountSettingsSyncedJson': instance.accountSettingsSyncedJson,
  'hasPaidVip': instance.hasPaidVip,
  'pendingCloudDeletes': instance.pendingCloudDeletes,
  'lastEntryWalletId': instance.lastEntryWalletId,
};
