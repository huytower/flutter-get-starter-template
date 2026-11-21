/// The App Shell's only door into the app's features: contracts the shell
/// calls, implemented (with the cross-module coordinators) in `src/`.
///
/// The shell imports this barrel, plus `core/di/di.module.dart` for DI wiring;
/// never a file under `src/`.
library bridge;

export 'src/contracts/app_lifecycle_provider.dart';
export 'src/contracts/book_currency_provider.dart';
export 'src/contracts/main_shell_provider.dart';
export 'src/contracts/main_tab.dart';
export 'src/contracts/regional_settings_contract.dart';
export 'src/contracts/shell_route_paths.dart';
