import 'package:domain_features/core/helper/ai_advice_cache_datasource.dart';
import 'package:domain_features/features/report/domain/entities/ai_advice_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AiAdviceCacheDataSource dataSource;
  final advice = AiAdviceEntity(
    sections: const [
      AiAdviceSectionItem(status: AiAdviceSectionStatus.good, text: 'ok'),
    ],
    generatedAt: DateTime(2026, 10, 27),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dataSource = AiAdviceCacheDataSource();
    await dataSource.saveAdvice(
      advice: advice,
      fingerprint: 'fp',
      targetCurrency: 'VND',
      languageCode: 'en',
    );
  });

  group('getCachedAdvice', () {
    test('hits when fingerprint, currency and language all match', () async {
      final cached = await dataSource.getCachedAdvice(
        fingerprint: 'fp',
        targetCurrency: 'VND',
        languageCode: 'en',
      );

      expect(cached, advice);
    });

    test('misses when the app language changed', () async {
      final cached = await dataSource.getCachedAdvice(
        fingerprint: 'fp',
        targetCurrency: 'VND',
        languageCode: 'vi',
      );

      expect(cached, isNull);
    });
  });

  group('getLastCachedAdvice', () {
    test(
      'returns the last advice only for the language it was made in',
      () async {
        expect(
          await dataSource.getLastCachedAdvice(languageCode: 'en'),
          advice,
        );
        expect(
          await dataSource.getLastCachedAdvice(languageCode: 'vi'),
          isNull,
        );
      },
    );

    test('ignores an entry saved before languages were tracked', () async {
      SharedPreferences.setMockInitialValues({
        'ai_advice_cached_json':
            '{"sections":[{"status":"good","text":"cũ","highlights":[]}],'
            '"generatedAt":"2026-10-27T00:00:00.000"}',
      });

      expect(await dataSource.getLastCachedAdvice(languageCode: 'vi'), isNull);
    });
  });
}
