import 'package:cc_sdk_ui/export_cc_sdk_ui.dart'
    show
        CcPaddingParams,
        CcReferenceWindow,
        CcReferenceWindows,
        ResponsiveExtension;
import 'package:domain_features/features/transaction/presentation/widgets/base/category_selection_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../adaptive/adaptive_test_devices.dart';

/// Runs [body] with a BuildContext laid out on [device].
Future<void> _withContext(
  WidgetTester tester,
  CcReferenceWindow device,
  void Function(BuildContext context) body,
) async {
  setTestDevice(tester, device);
  await tester.pumpWidget(
    Builder(
      builder: (context) {
        body(context);
        return const SizedBox.shrink();
      },
    ),
  );
}

void main() {
  testWidgets('phones: no inset keeps symmetric leading padding', (
    tester,
  ) async {
    await _withContext(tester, CcReferenceWindows.phone, (context) {
      final leading = context.respPadding(CcPaddingParams.PAGE_SM);
      final width = CcReferenceWindows.phone.size.width;
      final scrolling = CategoryGridMetrics.of(
        context,
        viewportWidth: width,
        itemCount: 40,
      );
      expect(scrolling.start, leading);
      expect(scrolling.end, leading);
      expect(
        scrolling.columns,
        greaterThanOrEqualTo(CategoryGridMetrics.minColumns),
      );
    });
  });

  testWidgets('wide + scrolling: starts at the content, bleeds to the edge', (
    tester,
  ) async {
    await _withContext(tester, CcReferenceWindows.tablet10.landscape, (
      context,
    ) {
      const viewport = 1184.0; // 1280 dp minus a 96 dp rail
      const inset = (viewport - 840) / 2;
      final leading = context.respPadding(CcPaddingParams.PAGE_SM);
      final bleed = CategoryGridMetrics.of(
        context,
        viewportWidth: viewport,
        itemCount: 40,
        inset: inset,
      );
      final capped = CategoryGridMetrics.of(
        context,
        viewportWidth: 840,
        itemCount: 40,
      );
      expect(bleed.start, leading + inset);
      expect(bleed.end, leading);
      // More columns than the capped column: the extra room is used.
      expect(bleed.columns, greaterThan(capped.columns));
      // Cards keep about the same size as in the capped column.
      expect(
        bleed.itemWidth,
        closeTo(capped.itemWidth, capped.itemWidth * 0.2),
      );
    });
  });

  testWidgets('wide + fits one page: stays inside the content column', (
    tester,
  ) async {
    await _withContext(tester, CcReferenceWindows.tablet10.landscape, (
      context,
    ) {
      const viewport = 1184.0;
      const inset = (viewport - 840) / 2;
      final metrics = CategoryGridMetrics.of(
        context,
        viewportWidth: viewport,
        itemCount: 4,
        inset: inset,
      );
      expect(metrics.start, metrics.end);
      final used =
          metrics.start +
          metrics.columns * metrics.itemWidth +
          (metrics.columns - 1) * metrics.gap +
          metrics.end;
      expect(used, closeTo(viewport, 0.01));
    });
  });
}
