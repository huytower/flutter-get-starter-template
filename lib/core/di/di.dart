import 'package:domain_features/features/guideline/guideline_controller.dart';
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

  Get.lazyPut(() => getIt<GuidelineController>());
}
