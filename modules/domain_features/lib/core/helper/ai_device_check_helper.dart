/// Detects the Firebase App Check (device attestation) failure that blocks AI
/// calls on devices that are not genuine — rooted/emulated builds or ones
/// whose debug token is not registered. Such calls fail with
/// `[firebase_app_check/...] ... code: 403 body: App attestation failed.`
bool isDeviceAttestationFailure(Object? error) {
  if (error == null) return false;
  final text = error.toString().toLowerCase();
  return text.contains('firebase_app_check') ||
      text.contains('app attestation failed') ||
      text.contains('app check');
}
