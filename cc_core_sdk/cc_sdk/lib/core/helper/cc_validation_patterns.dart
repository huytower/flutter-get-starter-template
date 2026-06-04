/// Common validation regex patterns.
abstract final class CcValidationPatterns {
  CcValidationPatterns._();

  /// Phone numbers with optional `+0` or `0` prefix, 10–12 digits.
  static const String phone = r'(^(?:[+0]9)?[0-9]{10,12}$)';

  /// Standard email format.
  static const String email =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  /// Alphanumeric name with spaces.
  static const String name = r'[A-Za-z0-9 ]{1,}';

  /// Simple phone number (1–15 digits).
  static const String phoneNumber = r'[0-9]{1,15}';
}
