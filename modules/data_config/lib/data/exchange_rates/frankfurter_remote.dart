import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import 'frankfurter_rate.dart';

export 'frankfurter_rate.dart';

part 'frankfurter_remote.g.dart';

/// Frankfurter API client using https://api.frankfurter.dev (Frankfurter v2).
/// `/v2/rates` returns a JSON array with one [FrankfurterRate] per quote.
@lazySingleton
@RestApi(baseUrl: 'https://api.frankfurter.dev')
abstract class FrankfurterRemote {
  @factoryMethod
  factory FrankfurterRemote(@Named('baseDio') Dio dio) = _FrankfurterRemote;

  /// Rates from [base] to each of [quotes] (comma-separated ISO codes), on
  /// [date] (`yyyy-MM-dd`) or the latest published day when null.
  @GET('/v2/rates')
  Future<List<FrankfurterRate>> getRates(
    @Query('base') String base,
    @Query('quotes') String quotes,
    @Query('date') String? date,
  );
}
