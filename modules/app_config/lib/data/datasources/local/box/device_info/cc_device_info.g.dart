// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cc_device_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CcDeviceInfoAdapter extends TypeAdapter<CcDeviceInfo> {
  @override
  final typeId = 3;

  @override
  CcDeviceInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CcDeviceInfo(
      appVersion: fields[0] as String?,
      deviceId: fields[1] as String?,
      serialNumber: fields[2] as String?,
      deviceWidth: (fields[3] as num?)?.toDouble(),
      deviceHeight: (fields[4] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, CcDeviceInfo obj) {
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
      other is CcDeviceInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CcDeviceInfo _$CcDeviceInfoFromJson(Map<String, dynamic> json) => CcDeviceInfo(
  appVersion: json['appVersion'] as String?,
  deviceId: json['deviceId'] as String?,
  serialNumber: json['serialNumber'] as String?,
  deviceWidth: (json['deviceWidth'] as num?)?.toDouble(),
  deviceHeight: (json['deviceHeight'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CcDeviceInfoToJson(CcDeviceInfo instance) =>
    <String, dynamic>{
      'appVersion': instance.appVersion,
      'deviceId': instance.deviceId,
      'serialNumber': instance.serialNumber,
      'deviceWidth': instance.deviceWidth,
      'deviceHeight': instance.deviceHeight,
    };
