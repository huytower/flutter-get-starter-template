import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/wallet_model.dart';

part 'wallet_remote.g.dart';

@lazySingleton
@RestApi()
abstract class WalletRemote {
  @factoryMethod
  factory WalletRemote(@Named('baseDio') Dio dio) = _WalletRemote;

  @GET('/wallets')
  Future<List<WalletModel>> getWallets();

  @GET('/wallets/{id}')
  Future<WalletModel> getWallet(@Path('id') String id);

  @POST('/wallets')
  Future<WalletModel> createWallet(@Body() WalletModel wallet);

  @PUT('/wallets/{id}')
  Future<WalletModel> updateWallet(@Path('id') String id, @Body() WalletModel wallet);

  @DELETE('/wallets/{id}')
  Future<void> deleteWallet(@Path('id') String id);
}
