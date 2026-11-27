import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/report/presentation/widgets/report_source_chip.dart';
import 'package:domain_features/features/report/presentation/widgets/report_transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _text(String value) => find.text(value, findRichText: true);

Future<void> _pump(WidgetTester tester, {required String sourceName}) async {
  tester.view.physicalSize = const Size(360, 800) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ReportTransactionTile(
          transaction: TransactionEntity(
            id: '1',
            type: TransactionType.investmentOut,
            amount: 500000,
            category: 'Shares',
            note: 'Contribute',
            date: DateTime(2026, 11, 27),
            walletId: 'cash',
            investmentWalletId: 'vcb',
          ),
          hasEditMode: false,
          sourceName: sourceName,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the source chip hugs its label, right of the title', (
    tester,
  ) async {
    await _pump(tester, sourceName: 'VCB');

    final title = tester.getRect(_text('Shares'));
    final label = tester.getRect(_text('VCB'));
    final chip = tester.getRect(find.byType(ReportSourceChip));

    expect(chip.left, greaterThanOrEqualTo(title.right));
    expect(chip.center.dy, moreOrLessEquals(title.center.dy, epsilon: 1));
    expect(chip.width, lessThan(label.width + 32));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long source name stays inside the row', (tester) async {
    await _pump(tester, sourceName: 'A very long investment position ' * 4);

    final chip = tester.getRect(find.byType(ReportSourceChip));
    final amount = tester.getRect(find.textContaining('-', findRichText: true));

    expect(chip.right, lessThanOrEqualTo(amount.left));
    expect(tester.takeException(), isNull);
  });
}
