import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/report/domain/entities/ai_advice_entity.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';

/// Local data source for caching AI Advice responses based on transaction fingerprints.
@lazySingleton
class AiAdviceCacheDataSource {
  static const String _keyCachedAdviceJson = 'ai_advice_cached_json';
  static const String _keyCachedFingerprint = 'ai_advice_cached_fingerprint';
  static const String _keyCachedCurrency = 'ai_advice_cached_currency';
  static const String _keyCachedLanguage = 'ai_advice_cached_language';

  /// Computes a deterministic fingerprint for a list of transactions.
  String computeFingerprint(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return 'empty';
    final sorted = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => a.id.compareTo(b.id));
    final buffer = StringBuffer();
    for (final t in sorted) {
      buffer.write(
        '${t.id}:${t.amount}:${t.type}:${t.date.millisecondsSinceEpoch}:${t.walletId}|',
      );
    }
    return buffer.toString();
  }

  /// Returns cached [AiAdviceEntity] if the stored transaction fingerprint,
  /// target currency and language match the given parameters. Returns null
  /// otherwise.
  Future<AiAdviceEntity?> getCachedAdvice({
    required String fingerprint,
    required String targetCurrency,
    required String languageCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedFingerprint = prefs.getString(_keyCachedFingerprint);
      final storedCurrency = prefs.getString(_keyCachedCurrency);
      final storedLanguage = prefs.getString(_keyCachedLanguage);

      if (storedFingerprint != fingerprint ||
          storedCurrency != targetCurrency ||
          storedLanguage != languageCode) {
        return null;
      }

      final jsonString = prefs.getString(_keyCachedAdviceJson);
      if (jsonString == null || jsonString.isEmpty) return null;

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) return null;

      return AiAdviceEntity.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  /// Returns the most recently saved [AiAdviceEntity] regardless of fingerprint,
  /// as long as it was generated in [languageCode].
  Future<AiAdviceEntity?> getLastCachedAdvice({
    required String languageCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_keyCachedLanguage) != languageCode) return null;
      final jsonString = prefs.getString(_keyCachedAdviceJson);
      if (jsonString == null || jsonString.isEmpty) return null;

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) return null;

      return AiAdviceEntity.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  /// Saves the [AiAdviceEntity] along with its transaction fingerprint,
  /// target currency and language into local persistent storage.
  Future<void> saveAdvice({
    required AiAdviceEntity advice,
    required String fingerprint,
    required String targetCurrency,
    required String languageCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCachedAdviceJson, jsonEncode(advice.toJson()));
      await prefs.setString(_keyCachedFingerprint, fingerprint);
      await prefs.setString(_keyCachedCurrency, targetCurrency);
      await prefs.setString(_keyCachedLanguage, languageCode);
    } catch (_) {}
  }

  /// Clears the cached advice.
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCachedAdviceJson);
      await prefs.remove(_keyCachedFingerprint);
      await prefs.remove(_keyCachedCurrency);
      await prefs.remove(_keyCachedLanguage);
    } catch (_) {}
  }
}
