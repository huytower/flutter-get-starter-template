import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/profile/presentation/get_x/profile_controller.dart';

final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the domain_features library.
/// Uses the Micro-Package pattern for injectable.
@InjectableInit.microPackage()
void initMicroPackage() {
  Get.lazyPut(() => getIt<ProfileController>());
}
