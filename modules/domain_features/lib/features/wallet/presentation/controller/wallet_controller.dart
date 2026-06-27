import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<WalletController>());
  }
}

@injectable
class WalletController extends CcGetController {
  WalletController(this._repository);

  final WalletRepository _repository;

  final RxInt currentNavIndex = 1.obs;
  final RxBool isBalanceVisible = true.obs;

  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final RxDouble totalBalance = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    loadWallets();
  }

  Future<void> loadWallets() async {
    layoutStatus.value = CcLayoutStatus.loading;

    final result = await _repository.getWallets();

    result.when(
      (success) {
        wallets.assignAll(success);
        _calculateTotalBalance();
        if (wallets.isEmpty) {
          layoutStatus.value = CcLayoutStatus.empty;
        } else {
          layoutStatus.value = CcLayoutStatus.success;
        }
      },
      (error) {
        errorMessage.value = error.message;
        layoutStatus.value = CcLayoutStatus.error;
      },
    );
  }

  void _calculateTotalBalance() {
    totalBalance.value = wallets.fold(0, (sum, item) => sum + item.balance);
  }

  Future<void> addWallet({
    required String name,
    required double initialBalance,
    required int iconCode,
    String type = 'spending',
  }) async {
    final newWallet = WalletEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      balance: initialBalance,
      iconCode: iconCode,
      type: type,
      createdAt: DateTime.now(),
    );

    final result = await _repository.addWallet(newWallet);

    result.when(
      (success) {
        wallets.add(newWallet);
        _calculateTotalBalance();
      },
      (error) {
        errorMessage.value = error.message;
      },
    );
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    final result = await _repository.updateWallet(wallet);

    result.when(
      (success) {
        final index = wallets.indexWhere((e) => e.id == wallet.id);
        if (index != -1) {
          wallets[index] = wallet;
          _calculateTotalBalance();
        }
      },
      (error) {
        errorMessage.value = error.message;
      },
    );
  }

  Future<void> deleteWallet(String id) async {
    final result = await _repository.deleteWallet(id);

    result.when(
      (success) {
        wallets.removeWhere((e) => e.id == id);
        _calculateTotalBalance();
      },
      (error) {
        errorMessage.value = error.message;
      },
    );
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
  }

  void setNavIndex(int index) {
    currentNavIndex.value = index;
  }
}
