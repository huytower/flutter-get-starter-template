import 'package:cc_sdk/export_cc_sdk.dart';

import '../../features/transaction/domain/entities/transaction_entity.dart';

/// Radius within which a past expense counts as "the same place" — wide
/// enough to tolerate GPS drift, tight enough not to blur together unrelated
/// shops in a dense area.
const double locationMatchRadiusMeters = 150;

/// Phase 3.5 location-based suggestion: among [candidates] (each must carry
/// non-null [TransactionEntity.lat]/[TransactionEntity.lng]), returns the
/// nearest one to ([lat],[lng]) — offered as a one-tap prefill suggestion,
/// same contract as `findBestMerchantMatch`. Null when nothing is within
/// [radiusMeters].
TransactionEntity? findNearbyExpenseMatch({
  required double lat,
  required double lng,
  required List<TransactionEntity> candidates,
  double radiusMeters = locationMatchRadiusMeters,
}) {
  TransactionEntity? nearest;
  double nearestDistance = double.infinity;

  for (final candidate in candidates) {
    final candidateLat = candidate.lat;
    final candidateLng = candidate.lng;
    if (candidateLat == null || candidateLng == null) continue;

    final distance = CcLocationHelper.distanceBetweenMeters(
      lat,
      lng,
      candidateLat,
      candidateLng,
    );
    if (distance <= radiusMeters && distance < nearestDistance) {
      nearest = candidate;
      nearestDistance = distance;
    }
  }

  return nearest;
}
