/// Response model for Frankfurter API v2 rate objects.
class FrankfurterResponse {
  const FrankfurterResponse({
    required this.base,
    required this.date,
    required this.rates,
  });

  final String base;
  final String date;
  final Map<String, double> rates;

  factory FrankfurterResponse.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = <String, double>{};
    for (final entry in rawRates.entries) {
      final val = entry.value;
      if (val is num) {
        parsedRates[entry.key.toUpperCase()] = val.toDouble();
      }
    }
    return FrankfurterResponse(
      base: json['base'] as String? ?? json['currency'] as String? ?? 'EUR',
      date: json['date'] as String? ?? DateTime.now().toIso8601String(),
      rates: parsedRates,
    );
  }

  Map<String, dynamic> toJson() => {'base': base, 'date': date, 'rates': rates};
}

