import 'package:cc_sdk_ui/core/enum/cc_layout_status.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/repositories/home_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<HomeController>());
  }
}

class HomeController extends CcGetController {
  HomeController(this._repository);

  final HomeRepository _repository;

  @override
  void onReady() {
    super.onReady();

    // Example of fetching data when the controller is ready
    fetchHomeData();
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
