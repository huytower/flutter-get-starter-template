import 'package:equatable/equatable.dart';

/// Entity representing a user in the system.
class CcUserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const CcUserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}
