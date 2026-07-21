import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Result<List<WalletEntity>, CcFailure>> getWallets();

  Future<Result<WalletEntity, CcFailure>> getWallet(String id);

  Future<Result<void, CcFailure>> addWallet(WalletEntity wallet);

  Future<Result<void, CcFailure>> updateWallet(WalletEntity wallet);

  Future<Result<void, CcFailure>> deleteWallet(String id);

  /// Syncs a specific wallet to Firestore.
  Future<Result<void, CcFailure>> syncWallet(String id);

  /// Syncs all wallets from Firestore to local storage.
  Future<Result<void, CcFailure>> syncFromFirestore();
}
