import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the domain_features library.
/// Uses the Micro-Package pattern for injectable.
@InjectableInit.microPackage()
void initMicroPackage() {}
