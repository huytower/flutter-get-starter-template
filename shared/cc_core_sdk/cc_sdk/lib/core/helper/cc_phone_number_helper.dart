import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Helper class for phone number validation and formatting.
class CcPhoneNumberHelper {
  CcPhoneNumberHelper._();

  /// Validates a phone number using phone_numbers_parser library.
  ///
  /// Returns true if the phone number is valid according to international standards.
  ///
  /// Example:
  /// - +84939722577 is valid (Vietnam number without leading zero)
  /// - +840939722577 is invalid (Vietnam number with leading zero after country code)
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return false;
    }

    try {
      final parsed = PhoneNumber.parse(phoneNumber);
      return parsed.isValid(type: PhoneNumberType.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Formats a phone number to international format.
  ///
  /// Returns the formatted phone number or null if invalid.
  static String? formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return null;
    }

    try {
      final parsed = PhoneNumber.parse(phoneNumber);
      if (parsed.isValid(type: PhoneNumberType.mobile)) {
        return parsed.international;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Gets the country code from a phone number.
  ///
  /// Returns the country code (e.g., '+84' for Vietnam) or null if invalid.
  static String? getCountryCode(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return null;
    }

    try {
      final parsed = PhoneNumber.parse(phoneNumber);
      if (parsed.isValid(type: PhoneNumberType.mobile)) {
        return parsed.countryCode;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Auto-parses a phone number by removing leading zeros from the national number.
  ///
  /// Takes a country code and a national number, removes leading zeros from the national number,
  /// and combines them to form a valid international phone number.
  ///
  /// Example:
  /// - countryCode: "+84", nationalNumber: "0939722577" → returns "+84939722577"
  /// - countryCode: "+84", nationalNumber: "939722577" → returns "+84939722577"
  static String autoParsePhoneNumber(
    String countryCode,
    String nationalNumber,
  ) {
    if (countryCode.isEmpty || nationalNumber.isEmpty) {
      return '$countryCode$nationalNumber';
    }

    // Remove leading zeros from national number
    final parsedNationalNumber = nationalNumber.replaceFirst(
      RegExp(r'^0+'),
      '',
    );

    return '$countryCode$parsedNationalNumber';
  }
}
