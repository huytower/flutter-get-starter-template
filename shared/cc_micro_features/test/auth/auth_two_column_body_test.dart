import 'package:cc_micro_features/features/auth/presentation/pages/widgets/auth_two_column_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _header = Key('header');
const _form = Key('form');

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: AuthTwoColumnBody(
          header: [SizedBox(key: _header, height: 40, width: 100)],
          form: [SizedBox(key: _form, height: 40, width: 100)],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('portrait / phones: header above the form', (tester) async {
    await _pump(tester, const Size(800, 1280));
    final header = tester.getRect(find.byKey(_header));
    final form = tester.getRect(find.byKey(_form));
    expect(form.top, greaterThanOrEqualTo(header.bottom));
    expect(
      AuthTwoColumnBody.cardMaxWidth(
        tester.element(find.byType(AuthTwoColumnBody)),
      ),
      isNull,
    );
  });

  testWidgets('landscape tablet: header left, form right, wider card', (
    tester,
  ) async {
    await _pump(tester, const Size(1280, 800));
    final header = tester.getRect(find.byKey(_header));
    final form = tester.getRect(find.byKey(_form));
    expect(form.left, greaterThan(header.right));
    expect(
      AuthTwoColumnBody.cardMaxWidth(
        tester.element(find.byType(AuthTwoColumnBody)),
      ),
      1000,
    );
  });
}
