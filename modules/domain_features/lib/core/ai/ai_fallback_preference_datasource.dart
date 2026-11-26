import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the cloud-LLM fallback's enabled flag and per-day call counter
/// (auto-resets when the stored date is no longer today).
@lazySingleton
class AiFallbackPreferenceDataSource {
  static const String _keyCallCountDate = 'ai_fallback_call_count_date';
  static const String _keyCallCount = 'ai_fallback_call_count';
  static const String _keyGeminiEnabled = 'ai_gemini_enabled';

  /// Default daily cap on cloud-LLM fallback calls (5 calls/day).
  static const int dailyCallLimit = 5;

  /// Whether to enforce the daily limit.
  /// Defaults to [!kDebugMode] (bypassed in debug builds, enforced in release).
  @visibleForTesting
  bool enforceDailyLimit = !kDebugMode;

  /// Last known value of [hasGeminiEnabled]; null until it is first read.
  final ValueNotifier<bool?> _geminiEnabled = ValueNotifier<bool?>(null);

  /// Live view of [hasGeminiEnabled] for the widgets that lock the AI
  /// features until the user agrees. Null while the stored value is still
  /// loading (the first read starts here); updated by [setGeminiEnabled].
  ValueListenable<bool?> get geminiEnabledListenable {
    if (_geminiEnabled.value == null) unawaited(hasGeminiEnabled());
    return _geminiEnabled;
  }

  /// Whether the user agreed to share data with Gemini (Google). Opt-in:
  /// defaults to false, so nothing leaves the device until the user allows it
  /// in the AI consent sheet (App Store guidelines 5.1.1(i) / 5.1.2(i)).
  Future<bool> hasGeminiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_keyGeminiEnabled) ?? false;
    _geminiEnabled.value = value;
    return value;
  }

  Future<void> setGeminiEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGeminiEnabled, value);
    _geminiEnabled.value = value;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Returns today's fallback-call count, transparently resetting to 0 if
  /// the last recorded call happened on an earlier day.
  Future<int> getTodayFallbackCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keyCallCountDate) != _todayKey()) return 0;
    return prefs.getInt(_keyCallCount) ?? 0;
  }

  Future<bool> hasUnderDailyLimit() async {
    if (!enforceDailyLimit) return true;
    return await getTodayFallbackCount() < dailyCallLimit;
  }

  Future<void> incrementTodayFallbackCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final current = prefs.getString(_keyCallCountDate) == today
        ? prefs.getInt(_keyCallCount) ?? 0
        : 0;
    await prefs.setString(_keyCallCountDate, today);
    await prefs.setInt(_keyCallCount, current + 1);
  }

  /// Future-chain mutex serializing [tryConsumeDailyCall]. Nothing may
  /// await between reading and replacing [_lock], or the chain stops
  /// serializing.
  Future<void> _lock = Future.value();

  /// Atomically checks-and-increments the daily call count — a plain
  /// [hasUnderDailyLimit] + [incrementTodayFallbackCount] pair would let two
  /// overlapping callers both read the same pre-increment count and both
  /// slip through over the cap. Returns false, count untouched, once the
  /// cap is reached for today.
  Future<bool> tryConsumeDailyCall() async {
    if (!enforceDailyLimit) return true;
    final previous = _lock;
    final completer = Completer<void>();
    _lock = completer.future;
    await previous;
    try {
      final count = await getTodayFallbackCount();
      if (count >= dailyCallLimit) return false;
      await incrementTodayFallbackCount();
      return true;
    } finally {
      completer.complete();
    }
  }
}
