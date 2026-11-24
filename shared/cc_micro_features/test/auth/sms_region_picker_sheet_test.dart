import 'package:cc_micro_features/features/auth/domain/sms_region.dart';
import 'package:cc_micro_features/features/auth/presentation/pages/widgets/sms_region_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<SmsRegion?> _open(
  WidgetTester tester,
  Size size, {
  Future<void> Function()? interact,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SmsRegion? picked;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await SmsRegionPickerSheet.show(
              context,
              selectedDialCode: '+84',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  if (interact != null) {
    await interact();
    await tester.pumpAndSettle();
  }
  return picked;
}

void main() {
  testWidgets('tablet: capped at 480 dp like the other sheets', (tester) async {
    await _open(tester, const Size(1000, 800));
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(SmsRegionPickerSheet)).width,
      lessThanOrEqualTo(480),
    );
  });

  testWidgets('phone: tapping a country returns it', (tester) async {
    final first = smsSupportedRegions.firstWhere((r) => r.isoCode == 'VN');
    final picked = await _open(
      tester,
      const Size(400, 900),
      interact: () => tester.tap(
        find.text('${first.isoCode}  ${first.dialCode}', findRichText: true),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(picked?.isoCode, 'VN');
  });
}
