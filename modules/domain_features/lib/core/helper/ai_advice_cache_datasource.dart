import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last Phase 3.8 AI-advice generation locally so revisiting
/// the Report page can show it for free (no cloud call, no daily-cap
/// consumption). Mirrors [AiFallbackPreferenceDataSource]'s
/// SharedPreferences-backed, single-purpose datasource shape and its
/// precedent of using SharedPreferences directly for local-only ephemeral
/// AI state rather than fanning through `CcAppStorage`/
/// `ProfileSettingsEntity`. Kept strictly primitive-in/primitive-out —
/// entity construction happens at the call sites.
@lazySingleton
class AiAdviceCacheDataSource {
  static const String _keyText = 'ai_advice_cached_text';
  static const String _keyGeneratedAtEpochMs = 'ai_advice_generated_at_epoch_ms';

  Future<String?> getCachedText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyText);
  }

  Future<DateTime?> getCachedGeneratedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final epochMs = prefs.getInt(_keyGeneratedAtEpochMs);
    if (epochMs == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epochMs);
  }

  Future<void> saveAdvice({
    required String text,
    required DateTime generatedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyText, text);
    await prefs.setInt(
      _keyGeneratedAtEpochMs,
      generatedAt.millisecondsSinceEpoch,
    );
  }
}
