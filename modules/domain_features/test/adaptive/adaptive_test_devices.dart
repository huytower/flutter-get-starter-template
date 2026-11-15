import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A logical screen (dp) to lay a widget out on in adaptive tests.
class AdaptiveTestDevice {
  final String name;
  final Size size;

  const AdaptiveTestDevice(this.name, this.size);

  /// The same device rotated 90°.
  AdaptiveTestDevice get landscape =>
      AdaptiveTestDevice('$name landscape', Size(size.height, size.width));

  @override
  String toString() => '$name (${size.width.toInt()}x${size.height.toInt()})';
}

/// Representative screens for the adaptive roadmap, in dp.
///
/// Covers every Material 3 width class plus the cases that broke before:
/// 16:10 small tablets, foldables and phone landscape.
abstract final class AdaptiveTestDevices {
  static const smallPhone = AdaptiveTestDevice('small phone', Size(320, 640));
  static const phone = AdaptiveTestDevice('phone', Size(390, 844));
  static const largePhone = AdaptiveTestDevice('large phone', Size(430, 932));
  static const foldCover = AdaptiveTestDevice('fold cover', Size(344, 882));
  static const foldInner = AdaptiveTestDevice('fold inner', Size(673, 841));
  static const tablet7 = AdaptiveTestDevice('7in tablet', Size(600, 960));
  static const tablet10 = AdaptiveTestDevice('10in tablet', Size(800, 1280));
  static const webDesktop = AdaptiveTestDevice('web desktop', Size(1440, 900));

  /// Portrait devices that must render without overflow today.
  static const portrait = [
    smallPhone,
    phone,
    largePhone,
    foldCover,
    foldInner,
    tablet7,
    tablet10,
  ];

  /// Landscape cases. Phones are portrait-locked, but tablets and unfolded
  /// foldables rotate (Android 16+ ignores the lock on screens >= 600 dp).
  static final landscape = [
    tablet7.landscape,
    tablet10.landscape,
    phone.landscape,
  ];

  /// Everything, including web/desktop.
  static final all = [...portrait, ...landscape, webDesktop];
}

/// Sets the test window to [device] (at 2x density) for the current test.
void setTestDevice(WidgetTester tester, AdaptiveTestDevice device) {
  tester.view.physicalSize = device.size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}
