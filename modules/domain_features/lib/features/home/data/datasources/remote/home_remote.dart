import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'home_remote.g.dart';

@singleton
@RestApi()
abstract class HomeRemote {
  @factoryMethod
  factory HomeRemote(@Named('baseDio') Dio dio) = _HomeRemote;
}
