import 'package:injectable/injectable.dart';

@lazySingleton
class RateFreshness {
  @factoryMethod
  factory RateFreshness.defaultPolicy() => const RateFreshness();

  const RateFreshness({
    this.maxAge = const Duration(hours: 24),
    this.warningThreshold = const Duration(hours: 12),
  });

  final Duration maxAge;
  final Duration? warningThreshold;

  bool isFresh(DateTime fetchedAt) {
    return DateTime.now().difference(fetchedAt) < maxAge;
  }
}

