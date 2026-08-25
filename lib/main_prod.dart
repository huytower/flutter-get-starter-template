import 'dart:developer' as developer;
import 'package:app_config/core/enum/environment.dart';

import 'core/runner/environment_runner.dart';

void main() {
  developer.log('🚀 main_prod.dart entry point | Environment=PROD | time=${DateTime.now().toIso8601String()}', name: 'Main');
  EnvironmentRunner.run(Environment.PROD);
  developer.log('✅ main_prod.dart | EnvironmentRunner.run() returned', name: 'Main');
}
