// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'res_header_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResHeaderModel _$ResHeaderModelFromJson(Map<String, dynamic> json) =>
    ResHeaderModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      code: json['code'] as String?,
      total: (json['total'] as num?)?.toInt(),
      error: json['error'] as String?,
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResHeaderModelToJson(ResHeaderModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'code': instance.code,
      'total': instance.total,
      'error': instance.error,
      'errors': instance.errors,
      'meta': instance.meta,
    };
