import 'package:cc_sdk_data/domain/entities/cc_user_entity.dart';
import 'package:data/domain/entities/auth/domain_user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

class DomainUserEntityConverter
    implements JsonConverter<DomainUserEntity?, Map<String, dynamic>?> {
  const DomainUserEntityConverter();

  @override
  DomainUserEntity? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return DomainUserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      status: _parseCcUserStatus(json['status'] as String?),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      registeredDeviceIds:
          (json['registeredDeviceIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic>? toJson(DomainUserEntity? entity) {
    if (entity == null) return null;

    return {
      'id': entity.id,
      'email': entity.email,
      'phoneNumber': entity.phoneNumber,
      'status': entity.status.name,
      'firstName': entity.firstName,
      'lastName': entity.lastName,
      'avatarUrl': entity.avatarUrl,
      'isEmailVerified': entity.isEmailVerified,
      'isPhoneVerified': entity.isPhoneVerified,
      'registeredDeviceIds': entity.registeredDeviceIds,
      'createdAt': entity.createdAt.toIso8601String(),
      'updatedAt': entity.updatedAt.toIso8601String(),
      'lastActiveAt': entity.lastActiveAt?.toIso8601String(),
    };
  }

  CcUserStatus _parseCcUserStatus(String? status) {
    if (status == null) return CcUserStatus.active;
    return CcUserStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => CcUserStatus.active,
    );
  }
}
