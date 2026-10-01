import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'frankfurter_remote.g.dart';

/// Frankfurter API client using https://api.frankfurter.dev (Frankfurter v2).
/// Supports /v2/rates and /v2/coverage.
@lazySingleton
@RestApi(baseUrl: 'https://api.frankfurter.dev')
abstract class FrankfurterRemote {
  @factoryMethod
  factory FrankfurterRemote(@Named('baseDio') Dio dio) = _FrankfurterRemote;

  /// Fetch rates with base, symbols, and optional date.
  @GET('/v2/rates')
  Future<FrankfurterResponse> getRates(
    @Query('base') String base,
    @Query('symbols') String? symbols,
    @Query('date') String? date,
  );
}

@JsonSerializable()
class FrankfurterResponse {
  const FrankfurterResponse({
    required this.base,
    required this.date,
    required this.rates,
  });

  final String base;
  final String date;
  final Map<String, double> rates;

  factory FrankfurterResponse.fromJson(Map<String, dynamic> json) =>
      _$FrankfurterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FrankfurterResponseToJson(this);
}
