import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets the test window to [window] (at 2x density) for the current test.
/// The windows themselves are shared: `CcReferenceWindows` in `cc_sdk_ui`.
void setTestDevice(WidgetTester tester, CcReferenceWindow window) {
  tester.view.physicalSize = window.size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}
