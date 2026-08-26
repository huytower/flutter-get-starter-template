import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';
import 'module/di_module_config.dart';
import 'package:bridge/navigation_bridge_service.dart';
import 'package:bridge/navigation_bridge_service_impl.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
  ignoreUnregisteredTypes: CcDiModuleConfig.ignoreUnregisteredTypes,
  externalPackageModulesBefore: CcDiModuleConfig.externalPackageModulesBefore,
)
Future<void> initializeDependencies() async {
  await getIt.init();

  getIt.registerLazySingleton<NavigationBridgeService>(
    () => NavigationBridgeServiceImpl(),
  );

  Get.lazyPut(() => getIt<GuidelineController>());
}
