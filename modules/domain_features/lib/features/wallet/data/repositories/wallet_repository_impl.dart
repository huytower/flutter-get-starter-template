import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local/wallet_local_datasource.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl with CcBaseRepository implements WalletRepository {
  @factoryMethod
  WalletRepositoryImpl({required WalletLocalDataSource local}) : _local = local;

  final WalletLocalDataSource _local;

  @override
  Future<Result<List<WalletEntity>, CcFailure>> getWallets() {
    // Cash always comes first, then by creation time — every consumer
    // (wallet lists, form dropdowns, reconcile tiles) inherits this order.
    return safeRequest(() async {
      final wallets = await _local.getWallets();
      wallets.sort((a, b) {
        final aCash = a.type == WalletType.cash ? 0 : 1;
        final bCash = b.type == WalletType.cash ? 0 : 1;
        if (aCash != bCash) return aCash - bCash;
        return a.createdAt.compareTo(b.createdAt);
      });
      return wallets;
    });
  }

  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) {
    return safeRequest(() async {
      final wallet = await _local.getWallet(id);
      if (wallet == null) {
        throw StateError('Wallet not found: $id');
      }
      return wallet;
    });
  }

  @override
  Future<Result<void, CcFailure>> addWallet(WalletEntity wallet) {
    return safeRequest(() => _local.addWallet(wallet));
  }

  @override
  Future<Result<void, CcFailure>> updateWallet(WalletEntity wallet) {
    return safeRequest(() => _local.updateWallet(wallet));
  }

  @override
  Future<Result<void, CcFailure>> deleteWallet(String id) {
    return safeRequest(() => _local.deleteWallet(id));
  }
}
