/// Types of biometric authentication supported by the domain
enum BiometricAuthTypeEntity {
  /// Face ID authentication
  faceId,

  /// Fingerprint authentication
  fingerprint,

  /// Face authentication (Android)
  face,

  /// No biometric authentication available
  none,
}
