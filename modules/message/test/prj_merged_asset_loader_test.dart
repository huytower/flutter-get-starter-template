import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:message/export_message.dart';

void main() {
  const package = <String, Map<String, dynamic>>{
    'en': {
      'mf': {'greeting': 'Hello', 'bye': 'Bye'},
      'app': {'name': 'package must not win'},
    },
    'vi': {
      'mf': {'greeting': 'Xin chào'},
    },
  };

  test('without package maps it returns the app map unchanged', () async {
    final map = await const PrjMergedAssetLoader().load('', const Locale('en'));
    expect(map, same(CodegenLoader.mapLocales['en']));
  });

  test('merges package keys and lets the app override them', () async {
    final map = await const PrjMergedAssetLoader(
      packageTranslations: [package],
    ).load('', const Locale('en'));

    expect(map!['mf'], {'greeting': 'Hello', 'bye': 'Bye'});
    expect(
      (map['app'] as Map<String, dynamic>)['name'],
      (CodegenLoader.mapLocales['en']!['app'] as Map<String, dynamic>)['name'],
    );
  });

  test('uses the package locale when present', () async {
    final map = await const PrjMergedAssetLoader(
      packageTranslations: [package],
    ).load('', const Locale('vi'));

    expect(map!['mf'], {'greeting': 'Xin chào'});
  });

  test('falls back to the package en map for a locale it lacks', () async {
    final map = await const PrjMergedAssetLoader(
      packageTranslations: [package],
    ).load('', const Locale('ja'));

    expect((map!['mf'] as Map<String, dynamic>)['greeting'], 'Hello');
  });

  test('does not mutate the package maps', () async {
    await const PrjMergedAssetLoader(
      packageTranslations: [package],
    ).load('', const Locale('en'));

    expect(package['en']!['app'], {'name': 'package must not win'});
  });
}
