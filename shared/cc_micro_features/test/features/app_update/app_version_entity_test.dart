import 'package:cc_micro_features/features/app_update/domain/entities/app_version_entity.dart';
import 'package:flutter_test/flutter_test.dart';

AppVersionEntity v(String raw) => AppVersionEntity.tryParse(raw)!;

void main() {
  group('AppVersionEntity.tryParse', () {
    test('parses semver with and without build number', () {
      expect(v('1.2.3').segments, [1, 2, 3]);
      expect(v('1.2.3').buildNumber, isNull);
      expect(v('1.2.3+25').buildNumber, 25);
      expect(v(' v2.0 ').segments, [2, 0]);
      expect(v('1.2.3-beta+4').segments, [1, 2, 3]);
      expect(v('1.2.3-beta+4').buildNumber, 4);
    });

    test('rejects empty, placeholder and malformed values', () {
      for (final raw in [
        null,
        '',
        '   ',
        'YOUR_MINIMUM_OS_VERSION_HAS_FORCE_HERE',
        '1..2',
        '1.a.0',
        '1.0.0+',
        '1.0.0+x',
        '1.0+2+3',
        '-1.0.0',
      ]) {
        expect(AppVersionEntity.tryParse(raw), isNull, reason: '$raw');
      }
    });

    test('toString round-trips', () {
      expect(v('1.2.3').toString(), '1.2.3');
      expect(v('1.2.3+25').toString(), '1.2.3+25');
    });
  });

  group('AppVersionEntity.compareTo', () {
    test('compares segments numerically, not as text', () {
      expect(v('1.9.0').isLowerThan(v('1.10.0')), isTrue);
      expect(v('1.10.0').isLowerThan(v('1.9.0')), isFalse);
      expect(v('2.0.0').isLowerThan(v('10.0.0')), isTrue);
    });

    test('missing segments count as zero', () {
      expect(v('1.2').compareTo(v('1.2.0')), 0);
      expect(v('1.2').isLowerThan(v('1.2.1')), isTrue);
    });

    test('equal versions are not lower', () {
      expect(v('1.2.0').isLowerThan(v('1.2.0')), isFalse);
      expect(v('1.2.0+5').isLowerThan(v('1.2.0+5')), isFalse);
    });

    test('build number breaks ties only when both sides have one', () {
      expect(v('1.2.0+29').isLowerThan(v('1.2.0+30')), isTrue);
      expect(v('1.2.0+31').isLowerThan(v('1.2.0+30')), isFalse);
      // Minimum without build number ignores the installed build.
      expect(v('1.2.0+1').isLowerThan(v('1.2.0')), isFalse);
      // Semver decides before build numbers are looked at.
      expect(v('1.1.9+999').isLowerThan(v('1.2.0+1')), isTrue);
      expect(v('1.2.1+1').isLowerThan(v('1.2.0+999')), isFalse);
    });
  });
}
