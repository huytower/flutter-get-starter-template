import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'frankfurter_remote.g.dart';

/// Frankfurter API client using https://api.frankfurter.dev (Frankfurter v2).
/// Note: Frankfurter v2 /v2/rates does not take a 'symbols' parameter;
/// it returns all available quotes for the base currency.
@lazySingleton
@RestApi(baseUrl: 'https://api.frankfurter.dev')
abstract class FrankfurterRemote {
  @factoryMethod
  factory FrankfurterRemote(@Named('baseDio') Dio dio) = _FrankfurterRemote;

  /// Fetch rates with base and optional date.
  @GET('/v2/rates')
  Future<FrankfurterResponse> getRates(
    @Query('base') String base,
    @Query('date') String? date,
  );
}

/// Hand-parsed response model for Frankfurter API to avoid code-gen map issues.
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
      base: json['base'] as String? ?? 'EUR',
      date: json['date'] as String? ?? '',
      rates: parsedRates,
    );
  }

  Map<String, dynamic> toJson() => {'base': base, 'date': date, 'rates': rates};
}
