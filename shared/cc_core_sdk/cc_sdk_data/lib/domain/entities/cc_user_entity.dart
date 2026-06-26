import 'package:equatable/equatable.dart';

/// Base User Entity - Universal user data structure.
/// This is a reusable entity that can be used across different business projects.
class CcUserEntity with EquatableMixin {
  final String id;
  final String email;
  final String? phoneNumber;
  final CcUserStatus status;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final List<String> registeredDeviceIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  const CcUserEntity({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.status,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.registeredDeviceIds,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  /// Display identifier for UI (email or phone)
  String get displayIdentifier {
    if (email.isNotEmpty) return email;
    if (phoneNumber != null) return phoneNumber!;
    return id;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phoneNumber,
    status,
    firstName,
    lastName,
    avatarUrl,
    isEmailVerified,
    isPhoneVerified,
    registeredDeviceIds,
    createdAt,
    updatedAt,
    lastActiveAt,
  ];
}

/// User status enum
enum CcUserStatus { active, inactive, suspended, pendingVerification }
