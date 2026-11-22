// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cc_app_track_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CcAppTrackLogAdapter extends TypeAdapter<CcAppTrackLog> {
  @override
  final typeId = 4;

  @override
  CcAppTrackLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CcAppTrackLog(
      msg: (fields[0] as List?)?.cast<String>(),
      tag: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CcAppTrackLog obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.msg)
      ..writeByte(1)
      ..write(obj.tag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CcAppTrackLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CcAppTrackLog _$CcAppTrackLogFromJson(Map<String, dynamic> json) =>
    CcAppTrackLog(
      msg: (json['msg'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tag: json['tag'] as String?,
    );

Map<String, dynamic> _$CcAppTrackLogToJson(CcAppTrackLog instance) =>
    <String, dynamic>{'msg': instance.msg, 'tag': instance.tag};
