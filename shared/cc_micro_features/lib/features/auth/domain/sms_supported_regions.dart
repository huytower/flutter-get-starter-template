/// A country the app can send a phone-verification SMS to.
class SmsRegion {
  const SmsRegion(this.isoCode, this.dialCode);

  /// ISO 3166-1 alpha-2 code, e.g. `VN`.
  final String isoCode;

  /// International dial code including the plus sign, e.g. `+84`.
  final String dialCode;

  /// Flag emoji built from the ISO code (regional-indicator letters).
  String get flag => String.fromCharCodes(
    isoCode.codeUnits.map((unit) => unit - 0x41 + 0x1F1E6),
  );
}

/// Region used before the user picks another one.
const String defaultSmsDialCode = '+84';

/// Regions allowed by the Firebase "SMS region policy"
/// (Firebase Console > Authentication > Settings > SMS region policy).
///
/// Keep this list identical to that policy: a country missing here cannot be
/// chosen in the app, and a country missing from the policy is rejected by
/// Firebase when the SMS is requested. There is no automatic sync, so update
/// both places together.
const List<SmsRegion> smsSupportedRegions = <SmsRegion>[
  SmsRegion('VN', '+84'),
  SmsRegion('AE', '+971'),
  SmsRegion('AR', '+54'),
  SmsRegion('AT', '+43'),
  SmsRegion('AU', '+61'),
  SmsRegion('BE', '+32'),
  SmsRegion('BR', '+55'),
  SmsRegion('CL', '+56'),
  SmsRegion('CN', '+86'),
  SmsRegion('CO', '+57'),
  SmsRegion('CY', '+357'),
  SmsRegion('DE', '+49'),
  SmsRegion('EE', '+372'),
  SmsRegion('ES', '+34'),
  SmsRegion('FI', '+358'),
  SmsRegion('FR', '+33'),
  SmsRegion('GB', '+44'),
  SmsRegion('GR', '+30'),
  SmsRegion('HK', '+852'),
  SmsRegion('HR', '+385'),
  SmsRegion('IE', '+353'),
  SmsRegion('IL', '+972'),
  SmsRegion('IT', '+39'),
  SmsRegion('JP', '+81'),
  SmsRegion('KH', '+855'),
  SmsRegion('KR', '+82'),
  SmsRegion('LA', '+856'),
  SmsRegion('LT', '+370'),
  SmsRegion('LU', '+352'),
  SmsRegion('LV', '+371'),
  SmsRegion('MT', '+356'),
  SmsRegion('MX', '+52'),
  SmsRegion('MY', '+60'),
  SmsRegion('NL', '+31'),
  SmsRegion('NZ', '+64'),
  SmsRegion('PE', '+51'),
  SmsRegion('PH', '+63'),
  SmsRegion('PT', '+351'),
  SmsRegion('QA', '+974'),
  SmsRegion('SG', '+65'),
  SmsRegion('SI', '+386'),
  SmsRegion('SK', '+421'),
  SmsRegion('TH', '+66'),
  SmsRegion('TW', '+886'),
  SmsRegion('US', '+1'),
];
