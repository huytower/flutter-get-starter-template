import 'package:cc_micro_features/export_micro_features.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' show CcConfirmSheet;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// No EasyLocalization in these tests, so `tr` returns the key itself.
Finder _text(String text) => find.text(text, findRichText: true);

class _RecordingReporter implements CcFeedbackReporter {
  final sent = <CcFeedback>[];

  @override
  Future<bool> send(
    CcFeedback feedback, {
    CcFeedbackLabels labels = CcFeedbackLabels.english,
  }) async {
    sent.add(feedback);
    return true;
  }
}

Future<T?> _openSheet<T>(
  WidgetTester tester,
  Future<T?> Function(BuildContext context) open,
) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  T? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await open(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  group('DeleteAccountConfirmSheet', () {
    testWidgets('confirm calls back; account shown', (tester) async {
      var confirms = 0;
      await _openSheet<bool>(
        tester,
        (context) => DeleteAccountConfirmSheet.show(
          context,
          accountLabel: 'me@example.com',
          onConfirm: () => confirms++,
        ),
      );
      expect(_text('me@example.com'), findsOneWidget);

      await tester.tap(_text(CcMfLocaleKeys.auth_delete_account));
      await tester.pumpAndSettle();
      expect(confirms, 1);
      expect(find.byType(CcConfirmSheet), findsNothing);
      // Let the buttons' debounce timers run out.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('cancel closes without confirming', (tester) async {
      var confirms = 0;
      await _openSheet<bool>(
        tester,
        (context) => DeleteAccountConfirmSheet.show(
          context,
          onConfirm: () => confirms++,
        ),
      );

      await tester.tap(_text('Cancel'));
      await tester.pumpAndSettle();
      expect(confirms, 0);
      expect(find.byType(CcConfirmSheet), findsNothing);
      // Let the buttons' debounce timers run out.
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('LanguagePickerSheet', () {
    testWidgets('pick a language and OK returns it', (tester) async {
      Locale? picked;
      await _openSheet<Locale>(tester, (context) async {
        return picked = await LanguagePickerSheet.show(
          context,
          locales: const [Locale('en'), Locale('vi'), Locale('fr')],
        );
      });

      expect(_text(CcMfLocaleKeys.language_vietnamese), findsOneWidget);
      // Unknown language: its code and a globe.
      expect(_text('FR'), findsOneWidget);
      expect(_text('🌐'), findsOneWidget);

      await tester.tap(_text(CcMfLocaleKeys.language_vietnamese));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(_text('OK'));
      await tester.pumpAndSettle();
      expect(picked, const Locale('vi'));
    });
  });

  group('ReviewFeedbackSection', () {
    Future<_RecordingReporter> pumpSection(WidgetTester tester) async {
      final reporter = _RecordingReporter();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReviewFeedbackSection(
                feedbackReporter: reporter,
                praiseOptions: const ['Fast', 'Clean'],
                criticismOptions: const ['Slow sync'],
                rating: 4,
              ),
            ),
          ),
        ),
      );
      return reporter;
    }

    testWidgets('nothing picked or typed: nothing sent', (tester) async {
      final reporter = await pumpSection(tester);
      await tester.tap(_text(CcMfLocaleKeys.app_review_feedback_send));
      await tester.pump(const Duration(seconds: 5));
      expect(reporter.sent, isEmpty);
    });

    testWidgets('picked tags go out as praise / criticism', (tester) async {
      final reporter = await pumpSection(tester);
      await tester.tap(_text('Fast'));
      await tester.tap(_text('Slow sync'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(_text(CcMfLocaleKeys.app_review_feedback_send));
      await tester.pump(const Duration(seconds: 5));

      expect(reporter.sent, hasLength(1));
      expect(reporter.sent.single.praise, ['Fast']);
      expect(reporter.sent.single.criticism, ['Slow sync']);
      expect(reporter.sent.single.rating, 4);
    });
  });
}
