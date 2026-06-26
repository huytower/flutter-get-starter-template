import 'package:app_config/core/di/di.module.dart';
import 'package:cc_bridge/core/di/di.module.dart';
import 'package:cc_micro_features/core/di/di.module.dart';
import 'package:cc_sdk/core/di/di.module.dart';
import 'package:data/core/di/di.module.dart';
import 'package:domain_features/core/di/di.module.dart';
import 'package:injectable/injectable.dart';

/// Configuration for Dependency Injection.
/// Consolidates all types and modules from external packages.
class CcDiModuleConfig {
  /// Types that are registered in Micro-Packages but used as dependencies in lib/
  static const List<Type> ignoreUnregisteredTypes = [];

  /// The Micro-Package modules that must be initialized before the main app
  static const List<ExternalModule> externalPackageModulesBefore = [
    ExternalModule(CcSdkPackageModule),
    ExternalModule(DataPackageModule),
    ExternalModule(AppConfigPackageModule),
    ExternalModule(CcMicroFeaturesPackageModule),
    ExternalModule(DomainFeaturesPackageModule),
    ExternalModule(CcBridgePackageModule),
  ];
}
