import 'package:injectable/injectable.dart';

@lazySingleton
class RateFreshness {
  const RateFreshness({required this.maxAge, this.warningThreshold});

  final Duration maxAge;
  final Duration? warningThreshold;

  bool isFresh(DateTime fetchedAt) {
    return DateTime.now().difference(fetchedAt) < maxAge;
  }

  @factoryMethod
  static RateFreshness get defaultPolicy => const RateFreshness(
    maxAge: Duration(hours: 24),
    warningThreshold: Duration(hours: 12),
  );
}
