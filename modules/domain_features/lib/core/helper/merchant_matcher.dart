import 'package:string_similarity/string_similarity.dart';

import '../../features/transaction/domain/entities/transaction_entity.dart';
import 'merchant_match_helper.dart';

/// Shortest normalized query worth fuzzy-matching — Dice's-coefficient
/// bigram matching is unreliable below this length (see
/// [StringSimilarity.compareTwoStrings]'s own 2-char cutoff).
const int minMerchantQueryLength = 3;

class MerchantMatcher {
  MerchantMatcher(Iterable<TransactionEntity> transactions)
    : _candidates = [],
      _normalizedNotes = [] {
    for (final transaction in transactions) {
      final normalized = normalizeMerchantText(transaction.note ?? '');
      if (normalized.isEmpty) continue;
      _candidates.add(transaction);
      _normalizedNotes.add(normalized);
    }
  }

  final List<TransactionEntity> _candidates;
  final List<String> _normalizedNotes;

  TransactionEntity? findBest(String query, {double threshold = 0.5}) {
    final normalizedQuery = normalizeMerchantText(query);
    if (normalizedQuery.length < minMerchantQueryLength) return null;
    if (_candidates.isEmpty) return null;

    final result = StringSimilarity.findBestMatch(
      normalizedQuery,
      _normalizedNotes,
    );
    if (result.bestMatch.rating == null ||
        result.bestMatch.rating! < threshold) {
      return null;
    }
    return _candidates[result.bestMatchIndex];
  }
}
