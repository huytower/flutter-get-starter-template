import 'package:domain_features/core/presentation/widgets/highlighted_guide_row.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_availability_entity.dart';
import 'package:domain_features/features/reconciliation/presentation/widgets/reconciliation_locked_sheet.dart';
// Loads the real strings without the EasyLocalization widget and its storage.
// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message/export_message.dart';

Finder _text(String text) => find.textContaining(text, findRichText: true);

final _availability = ReconciliationAvailabilityEntity(
  cycleStart: DateTime.utc(2026, 11, 23),
  cycleEnd: DateTime.utc(2026, 11, 29),
  reconciledAt: DateTime(2026, 11, 28),
);

void main() {
  late bool? result;

  setUpAll(() async {
    const locale = Locale('vi');
    final strings = await const CodegenLoader().load('', locale);
    Localization.load(locale, translations: Translations(strings!));
  });

  Future<void> openSheet(WidgetTester tester) async {
    // A small phone, so long Vietnamese lines have to wrap.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result =
                  await ReconciliationLockedSheet.show(context, _availability),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists when, next, why and how as full bullets', (tester) async {
    await openSheet(tester);

    expect(find.byType(HighlightedGuideRow), findsNWidgets(4));
    // The whole next-cycle line is there (it used to be cut after "Chủ").
    expect(_text('từ Thứ Hai, 30/11 đến Chủ Nhật, 06/12.'), findsOneWidget);
    expect(_text('Thứ Bảy, 28/11'), findsOneWidget);
    expect(_text('**'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('view history comes before got it', (tester) async {
    await openSheet(tester);

    final history = tester.getCenter(_text('Xem lịch sử'));
    final gotIt = tester.getCenter(_text('Đã hiểu'));
    // Side by side, or stacked when the test font makes them too wide.
    expect(history.dy < gotIt.dy || history.dx < gotIt.dx, isTrue);
  });

  testWidgets('view history returns true', (tester) async {
    await openSheet(tester);

    await tester.tap(_text('Xem lịch sử'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('got it only closes', (tester) async {
    await openSheet(tester);

    await tester.tap(_text('Đã hiểu'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.byType(ReconciliationLockedSheet), findsNothing);
  });
}
