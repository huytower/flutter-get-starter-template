import 'dart:developer' as developer;
import 'package:app_config/core/enum/environment.dart';

import 'core/runner/environment_runner.dart';

void main() {
  developer.log('🚀 main_uat.dart entry point | Environment=UAT | time=${DateTime.now().toIso8601String()}', name: 'Main');
  EnvironmentRunner.run(Environment.UAT);
  developer.log('✅ main_uat.dart | EnvironmentRunner.run() returned', name: 'Main');
}
