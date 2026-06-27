import 'package:cc_sdk_ui/core/enum/cc_layout_status.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/repositories/home_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<HomeController>());
  }
}

@lazySingleton
class HomeController extends CcGetController {
  HomeController(this._repository, this._coordinator);

  final HomeRepository _repository;
  final HomeCoordinator _coordinator;

  @override
  void onReady() {
    super.onReady();
    fetchHomeData();
  }

  void navigateToWallet(BuildContext context) {
    _coordinator.navigateToWallet(context);
  }

  void navigateToTransaction(BuildContext context) {
    _coordinator.navigateToTransaction(context);
  }

  void fetchHomeData() {
    layoutStatus.value = CcLayoutStatus.success;
    // Implement your data fetching logic here using _repository
    // For example:
    // _repository.getHomeData().then((data) {
    //   // Handle the fetched data
    // }).catchError((error) {
    //   // Handle any errors
    // });
  }
}
