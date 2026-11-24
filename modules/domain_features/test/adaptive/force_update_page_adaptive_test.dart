import 'package:cc_micro_features/features/app_update/domain/entities/app_update_status_entity.dart';
import 'package:cc_micro_features/features/app_update/domain/entities/app_version_entity.dart';
import 'package:cc_micro_features/features/app_update/presentation/pages/force_update_page.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' show CcReferenceWindows;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'adaptive_test_devices.dart';

/// The forced-update screen must fit every device in the adaptive matrix,
/// including tablets in landscape, without overflow.
void main() {
  final status = AppUpdateRequired(
    currentVersion: AppVersionEntity.tryParse('1.0.0+25')!,
    minimumVersion: AppVersionEntity.tryParse('1.2.0')!,
  );

  for (final device in CcReferenceWindows.all) {
    testWidgets('ForceUpdatePage lays out on $device', (tester) async {
      setTestDevice(tester, device);
      await tester.pumpWidget(
        MaterialApp(home: ForceUpdatePage(status: status)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ForceUpdatePage), findsOneWidget);
      expect(find.byIcon(Icons.system_update_rounded), findsOneWidget);
    });
  }
}
