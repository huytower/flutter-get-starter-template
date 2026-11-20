import 'package:cc_sdk_data/export_cc_sdk_data.dart';

/// Domain-specific User Entity that extends the Universal Base.
class DomainUserEntity extends CcUserEntity {
  const DomainUserEntity({
    required super.id,
    required super.email,
    super.phoneNumber,
    required super.status,
    super.firstName,
    super.lastName,
    super.avatarUrl,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.registeredDeviceIds,
    required super.createdAt,
    required super.updatedAt,
    super.lastActiveAt,
  });
}
