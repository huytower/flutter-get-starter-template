import 'dart:async';
import 'dart:math';

import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../datasources/local/wallet_local_datasource.dart';
import '../datasources/remote/wallet_remote.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl with CcBaseRepository
    implements WalletRepository {
  @factoryMethod
  WalletRepositoryImpl({
    required WalletRemote remote,
    required WalletLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final WalletRemote _remote;
  final WalletLocalDataSource _local;

  static const _walletNames = [
    'Main Wallet',
    'Savings',
    'Travel Fund',
    'Groceries',
    'Entertainment',
  ];

  static const _walletTypes = ['spending', 'savings', 'investment'];

  List<WalletEntity> _generateFakeWallets(int count) {
    final random = Random();
    return List.generate(count, (index) {
      return WalletEntity(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}_$index',
        name: _walletNames[index % _walletNames.length],
        balance: (random.nextDouble() * 50_000_000 + 100_000).roundToDouble(),
        iconCode: 0xe1e1,
        type: _walletTypes[index % _walletTypes.length],
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(90))),
      );
    });
  }

  @override
  Future<Result<List<WalletEntity>, CcFailure>> getWallets() {
    return safeRequest(() async {
      final fakeData = _generateFakeWallets(5);
      return fakeData;
    });
  }

  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) {
    return safeRequest(() async {
      final fakeWallets = _generateFakeWallets(1);
      return fakeWallets.first;
    });
  }

  @override
  Future<Result<void, CcFailure>> addWallet(WalletEntity wallet) {
    return safeRequest(() async {
      await _local.addWallet(wallet);
    });
  }

  @override
  Future<Result<void, CcFailure>> updateWallet(WalletEntity wallet) {
    return safeRequest(() async {
      await _remote.updateWallet(wallet.id, WalletModel(
        id: wallet.id,
        name: wallet.name,
        balance: wallet.balance,
        iconCode: wallet.iconCode,
        type: wallet.type,
        createdAt: wallet.createdAt.toIso8601String(),
      ));
      await _local.updateWallet(wallet);
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteWallet(String id) {
    return safeRequest(() async {
      await _remote.deleteWallet(id);
      await _local.deleteWallet(id);
    });
  }
}
