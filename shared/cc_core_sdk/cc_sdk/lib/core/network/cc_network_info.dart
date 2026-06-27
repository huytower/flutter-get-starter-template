import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

abstract class CcNetworkInfo {
  Future<bool> get isConnected;
}

@LazySingleton(as: CcNetworkInfo)
class CcNetworkInfoImpl implements CcNetworkInfo {
  final Connectivity connectivity;

  const CcNetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
}
