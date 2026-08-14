import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the two small pieces of local state the cloud-LLM fallback (see
/// `ParseQuickEntryUseCase`) needs: a one-time user consent flag, and a
/// per-day call counter that resets automatically when the stored date is no
/// longer today. Mirrors `AuthPreferenceDataSource`'s
/// SharedPreferences-backed, single-purpose datasource shape rather than
/// threading two unrelated fields through `CcAppStorage`/
/// `ProfileSettingsEntity`'s much larger fan-out.
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

  /// Serializes [tryConsumeDailyCall] calls behind an in-process
  /// Future-chain mutex — the standard Dart pattern for this (safe because
  /// nothing awaits between reading and replacing [_lock], so the chain
  /// itself can never race even though the critical section it guards is
  /// async).
  Future<void> _lock = Future.value();

  /// Atomically checks-and-increments the daily cloud-fallback call count.
  /// [isUnderDailyLimit] + a separate [incrementTodayFallbackCount] call is
  /// a classic check-then-act race: two overlapping callers (e.g. a
  /// double-submit the caller failed to debounce, or two separate
  /// `ExpenseFormController` instances open at once) could both read the
  /// same pre-increment count, both decide they're under the cap, and both
  /// proceed — silently letting more than [dailyCallLimit] calls through
  /// while the persisted counter only advances once per such race. This
  /// method closes that window by serializing the whole
  /// check-and-increment as one critical section. Returns false (and
  /// leaves the count untouched) once the cap is reached for today.
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
