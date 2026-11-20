import 'package:domain_features/features/profile/presentation/helper/profile_display_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileDisplayText.daysToNextAudit', () {
    // 2026-11-16 is a Monday.
    final monday = DateTime(2026, 11, 16);

    test('is 0 on the audit day', () {
      expect(ProfileDisplayText.daysToNextAudit(0, monday), 0);
    });

    test('counts forward within the week', () {
      expect(ProfileDisplayText.daysToNextAudit(6, monday), 6); // Sunday
    });

    test('wraps to next week once the audit day has passed', () {
      final wednesday = DateTime(2026, 11, 18);
      expect(ProfileDisplayText.daysToNextAudit(0, wednesday), 5);
    });
  });
}
