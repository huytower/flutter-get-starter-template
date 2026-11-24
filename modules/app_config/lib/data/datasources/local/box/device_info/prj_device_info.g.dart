// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prj_device_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrjDeviceInfoAdapter extends TypeAdapter<PrjDeviceInfo> {
  @override
  final typeId = 3;

  @override
  PrjDeviceInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrjDeviceInfo(
      appVersion: fields[0] as String?,
      deviceId: fields[1] as String?,
      serialNumber: fields[2] as String?,
      deviceWidth: (fields[3] as num?)?.toDouble(),
      deviceHeight: (fields[4] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, PrjDeviceInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.appVersion)
      ..writeByte(1)
      ..write(obj.deviceId)
      ..writeByte(2)
      ..write(obj.serialNumber)
      ..writeByte(3)
      ..write(obj.deviceWidth)
      ..writeByte(4)
      ..write(obj.deviceHeight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrjDeviceInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrjDeviceInfo _$PrjDeviceInfoFromJson(Map<String, dynamic> json) =>
    PrjDeviceInfo(
      appVersion: json['appVersion'] as String?,
      deviceId: json['deviceId'] as String?,
      serialNumber: json['serialNumber'] as String?,
      deviceWidth: (json['deviceWidth'] as num?)?.toDouble(),
      deviceHeight: (json['deviceHeight'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PrjDeviceInfoToJson(PrjDeviceInfo instance) =>
    <String, dynamic>{
      'appVersion': instance.appVersion,
      'deviceId': instance.deviceId,
      'serialNumber': instance.serialNumber,
      'deviceWidth': instance.deviceWidth,
      'deviceHeight': instance.deviceHeight,
    };
