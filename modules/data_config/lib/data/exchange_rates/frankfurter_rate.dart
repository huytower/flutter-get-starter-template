/// One rate object from Frankfurter v2 `GET /v2/rates`.
///
/// v2 answers with a JSON array holding one object per quote currency, e.g.
/// `{"date":"2026-11-26","base":"VND","quote":"USD","rate":0.0000387}`.
class FrankfurterRate {
  const FrankfurterRate({
    required this.base,
    required this.quote,
    required this.rate,
    required this.date,
  });

  factory FrankfurterRate.fromJson(Map<String, dynamic> json) {
    final rate = json['rate'];
    return FrankfurterRate(
      base: (json['base'] as String? ?? '').toUpperCase(),
      quote: (json['quote'] as String? ?? '').toUpperCase(),
      rate: rate is num ? rate.toDouble() : double.nan,
      date: json['date'] as String? ?? '',
    );
  }

  final String base;
  final String quote;
  final double rate;

  /// `yyyy-MM-dd` the rate is published for.
  final String date;

  Map<String, dynamic> toJson() => {
    'base': base,
    'quote': quote,
    'rate': rate,
    'date': date,
  };
}
