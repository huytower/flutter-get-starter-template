import 'package:cc_sdk/export_cc_sdk.dart';

import '../../features/transaction/domain/entities/transaction_entity.dart';

const double locationMatchRadiusMeters = 150;

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
