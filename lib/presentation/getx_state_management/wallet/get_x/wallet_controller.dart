import 'package:get/get.dart';

class WalletController extends GetxController {
  final RxInt currentNavIndex = 1.obs; // Default to Wallet tab
  final RxBool isBalanceVisible = true.obs;

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
  }

  void setNavIndex(int index) {
    currentNavIndex.value = index;
  }
}
