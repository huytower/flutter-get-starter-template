import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/transaction_model.dart';

part 'transaction_remote.g.dart';

@lazySingleton
@RestApi()
abstract class TransactionRemote {
  @factoryMethod
  factory TransactionRemote(@Named('baseDio') Dio dio) = _TransactionRemote;

  @GET('/transactions')
  Future<List<TransactionModel>> getTransactions(
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  @GET('/transactions')
  Future<List<TransactionModel>> getListTransactions();
}
