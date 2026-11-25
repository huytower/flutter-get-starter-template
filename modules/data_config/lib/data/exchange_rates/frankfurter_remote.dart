import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import 'frankfurter_response.dart';

export 'frankfurter_response.dart';

part 'frankfurter_remote.g.dart';

/// Frankfurter API client using https://api.frankfurter.dev (Frankfurter v2).
/// Note: Frankfurter v2 /v2/rates returns a JSON array of rate objects.
@lazySingleton
@RestApi(baseUrl: 'https://api.frankfurter.dev')
abstract class FrankfurterRemote {
  @factoryMethod
  factory FrankfurterRemote(@Named('baseDio') Dio dio) = _FrankfurterRemote;

  /// Fetch rates with base and optional date.
  @GET('/v2/rates')
  Future<List<FrankfurterResponse>> getRates(
    @Query('base') String base,
    @Query('date') String? date,
  );
}
