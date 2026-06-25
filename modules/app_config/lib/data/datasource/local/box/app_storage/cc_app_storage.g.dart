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
    );
  }

  @override
  void write(BinaryWriter writer, CcAppStorage obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.user);
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
);

Map<String, dynamic> _$CcAppStorageToJson(CcAppStorage instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'fcmToken': instance.fcmToken,
      'gpsLocation': instance.gpsLocation,
      'userRole': instance.userRole,
      'dashboardData': instance.dashboardData,
      'user': const DomainUserEntityConverter().toJson(instance.user),
    };
