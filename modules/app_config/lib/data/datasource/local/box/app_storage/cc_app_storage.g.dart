// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cc_app_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CcAppStorageAdapter extends TypeAdapter<CcAppStorage> {
  @override
  final typeId = 2;

  @override
  CcAppStorage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CcAppStorage(
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
      isDarkMode: fields[10] as bool?,
      completedGuidelineTaskIds: (fields[11] as List?)?.cast<String>(),
      weeklyAuditDayChangedAt: fields[12] as DateTime?,
      levelFeatureAnchorAt: fields[13] as DateTime?,
      isVip: fields[14] as bool?,
      highestUserLevelReached: (fields[16] as num?)?.toInt(),
      firstLaunchAt: fields[17] as DateTime?,
      cloudBackupReminderSentAt: fields[18] as DateTime?,
      hasViewedEmergencyFundEbook: fields[19] as bool?,
      hasSeenTutorial: fields[20] as bool?,
      isProfileHeaderFlipped: fields[21] as bool?,
      hasCustomizedCategories: fields[22] as bool?,
      hasInteractedWithTransactionCardStack: fields[23] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, CcAppStorage obj) {
    writer
      ..writeByte(23)
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
      ..write(obj.isDarkMode)
      ..writeByte(11)
      ..write(obj.completedGuidelineTaskIds)
      ..writeByte(12)
      ..write(obj.weeklyAuditDayChangedAt)
      ..writeByte(13)
      ..write(obj.levelFeatureAnchorAt)
      ..writeByte(14)
      ..write(obj.isVip)
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
      ..write(obj.isProfileHeaderFlipped)
      ..writeByte(22)
      ..write(obj.hasCustomizedCategories)
      ..writeByte(23)
      ..write(obj.hasInteractedWithTransactionCardStack);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CcAppStorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CcAppStorage _$CcAppStorageFromJson(Map<String, dynamic> json) => CcAppStorage(
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
  isDarkMode: json['isDarkMode'] as bool?,
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
  isVip: json['isVip'] as bool?,
  highestUserLevelReached: (json['highestUserLevelReached'] as num?)?.toInt(),
  firstLaunchAt: json['firstLaunchAt'] == null
      ? null
      : DateTime.parse(json['firstLaunchAt'] as String),
  cloudBackupReminderSentAt: json['cloudBackupReminderSentAt'] == null
      ? null
      : DateTime.parse(json['cloudBackupReminderSentAt'] as String),
  hasViewedEmergencyFundEbook: json['hasViewedEmergencyFundEbook'] as bool?,
  hasSeenTutorial: json['hasSeenTutorial'] as bool?,
  isProfileHeaderFlipped: json['isProfileHeaderFlipped'] as bool?,
  hasCustomizedCategories: json['hasCustomizedCategories'] as bool?,
  hasInteractedWithTransactionCardStack:
      json['hasInteractedWithTransactionCardStack'] as bool?,
);

Map<String, dynamic> _$CcAppStorageToJson(CcAppStorage instance) =>
    <String, dynamic>{
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
      'isDarkMode': instance.isDarkMode,
      'completedGuidelineTaskIds': instance.completedGuidelineTaskIds,
      'weeklyAuditDayChangedAt': instance.weeklyAuditDayChangedAt
          ?.toIso8601String(),
      'levelFeatureAnchorAt': instance.levelFeatureAnchorAt?.toIso8601String(),
      'isVip': instance.isVip,
      'highestUserLevelReached': instance.highestUserLevelReached,
      'firstLaunchAt': instance.firstLaunchAt?.toIso8601String(),
      'cloudBackupReminderSentAt': instance.cloudBackupReminderSentAt
          ?.toIso8601String(),
      'hasViewedEmergencyFundEbook': instance.hasViewedEmergencyFundEbook,
      'hasSeenTutorial': instance.hasSeenTutorial,
      'isProfileHeaderFlipped': instance.isProfileHeaderFlipped,
      'hasCustomizedCategories': instance.hasCustomizedCategories,
      'hasInteractedWithTransactionCardStack':
          instance.hasInteractedWithTransactionCardStack,
    };
