import 'package:domain_features/export_domain_features.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';
import 'module/di_module_config.dart';

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

  // Register global controllers with GetX after GetIt is ready.
  // These are controllers that need to be accessible before their
  // respective views are built (e.g. in the NavigationBar shell).
  Get.lazyPut(() => getIt<GuidelineController>());
}
