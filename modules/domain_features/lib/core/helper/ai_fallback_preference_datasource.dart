import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the cloud-LLM fallback's consent flag and per-day call counter
/// (auto-resets when the stored date is no longer today).
@lazySingleton
class AiFallbackPreferenceDataSource {
  static const String _keyConsentGiven = 'ai_fallback_consent_given';
  static const String _keyCallCountDate = 'ai_fallback_call_count_date';
  static const String _keyCallCount = 'ai_fallback_call_count';

  /// Default daily cap on cloud-LLM fallback calls, kept low enough to bound
  /// cost/abuse while comfortably covering normal quick-entry usage.
  static const int dailyCallLimit = 10;

  Future<bool> isConsentGiven() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConsentGiven) ?? false;
  }

  Future<void> setConsentGiven(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyConsentGiven, value);
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

  Future<bool> isUnderDailyLimit() async {
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
  /// [isUnderDailyLimit] + [incrementTodayFallbackCount] pair would let two
  /// overlapping callers both read the same pre-increment count and both
  /// slip through over the cap. Returns false, count untouched, once the
  /// cap is reached for today.
  Future<bool> tryConsumeDailyCall() async {
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
