import 'package:domain_features/core/ai/ai_fallback_preference_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('geminiEnabledListenable', () {
    test('is null until read, then loads the stored consent', () async {
      SharedPreferences.setMockInitialValues({'ai_gemini_enabled': true});
      final prefs = AiFallbackPreferenceDataSource();

      final listenable = prefs.geminiEnabledListenable;
      expect(listenable.value, isNull);

      await prefs.hasGeminiEnabled();
      expect(listenable.value, isTrue);
    });

    test('defaults to false (opt-in) when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AiFallbackPreferenceDataSource();

      expect(await prefs.hasGeminiEnabled(), isFalse);
      expect(prefs.geminiEnabledListenable.value, isFalse);
    });

    test('notifies when consent is granted or withdrawn', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AiFallbackPreferenceDataSource();
      final seen = <bool?>[];
      prefs.geminiEnabledListenable.addListener(
        () => seen.add(prefs.geminiEnabledListenable.value),
      );

      await prefs.setGeminiEnabled(true);
      await prefs.setGeminiEnabled(false);

      expect(seen, containsAllInOrder(<bool?>[true, false]));
      expect(await prefs.hasGeminiEnabled(), isFalse);
    });
  });
}
