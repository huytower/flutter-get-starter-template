import 'package:bridge/export_bridge.dart';
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

  getIt<AppLifecycleProvider>().registerPresentationBindings();
}
