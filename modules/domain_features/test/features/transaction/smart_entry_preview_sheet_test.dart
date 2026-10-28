import 'dart:convert';
import 'dart:io';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart'
    show CcBaseBtn, CcCancelBtn, CcLocaleKeys;
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:domain_features/features/transaction/domain/entities/parsed_transaction_entity.dart';
import 'package:domain_features/features/transaction/presentation/get_x/smart_entry_preview_state.dart';
import 'package:domain_features/features/transaction/presentation/widgets/smart_entry_preview_row_card.dart';
import 'package:domain_features/features/transaction/presentation/widgets/smart_entry_preview_sheet.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _food = CategoryEntity(
  id: 'food',
  nameKey: 'category.food',
  iconCode: 0xe532,
  groupId: 'g',
);
const _salary = CategoryEntity(
  id: 'salary',
  nameKey: 'category.salary',
  iconCode: 0xe532,
  groupId: 'g',
  type: CategoryType.income,
);

final _wallet = WalletEntity(
  id: 'w1',
  name: 'Cash',
  balance: 0,
  iconCode: 0xe532,
  type: WalletType.cash,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

String _confirmMany(int count) => el.tr(
  CcLocaleKeys.smart_entry_preview_confirm_many,
  namedArgs: {'count': '$count'},
);

String _titleMany(int count) => el.tr(
  CcLocaleKeys.smart_entry_preview_title_many,
  namedArgs: {'count': '$count'},
);

String get _confirmOne => el.tr(CcLocaleKeys.smart_entry_preview_confirm_one);

String get _income => el.tr(CcLocaleKeys.common_income);

Finder _text(String value) => find.text(value, findRichText: true);

Future<void> _loadRealisticText() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';
    final loader = FontLoader('Roboto');
    for (final name in ['Regular', 'Medium', 'Bold']) {
      final file = File('$fonts/Roboto-$name.ttf');
      if (file.existsSync()) {
        loader.addFont(
          Future.value(ByteData.sublistView(file.readAsBytesSync())),
        );
      }
    }
    await loader.load();
  }
  final raw = File('../message/assets/translations/vi.json').readAsStringSync();
  final json =
      jsonDecode(raw.replaceFirst('\uFEFF', '')) as Map<String, dynamic>;
  Localization.load(const Locale('vi'), translations: Translations(json));
}

SmartEntryPreviewState _state(
  List<ParsedTransactionEntity> parsed, {
  bool mixed = false,
}) => SmartEntryPreviewState(
  parsed: parsed,
  categories: const [_food, _salary],
  wallets: [_wallet],
  config: SmartEntryPreviewConfig(
    types: mixed
        ? const [CategoryType.expense, CategoryType.income]
        : const [CategoryType.expense],
    currencyCode: 'VND',
  ),
  defaultWalletId: 'w1',
  now: DateTime(2026, 10, 26, 12),
);

const _valid = ParsedTransactionEntity(
  type: CategoryType.expense,
  amount: 50000,
  categoryId: 'food',
  note: 'Pho',
);

Future<void> _open(
  WidgetTester tester,
  SmartEntryPreviewState state, {
  SmartEntryCommit? onConfirm,
  Size logicalSize = const Size(540, 1200),
}) async {
  tester.view.physicalSize = logicalSize * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => SmartEntryPreviewSheet.show(
                context,
                state: state,
                onConfirm:
                    onConfirm ??
                    (_) async => const SmartEntryCommitResult(saved: 0),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _flushDebounce(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 1));

Future<void> _tapConfirm(WidgetTester tester) async {
  await tester.tap(find.byType(CcBaseBtn));
  await tester.pumpAndSettle();
  await _flushDebounce(tester);
}

void main() {
  setUpAll(_loadRealisticText);

  testWidgets('shows one card per parsed row under a plural title', (
    tester,
  ) async {
    await _open(tester, _state([_valid, _valid]));

    expect(find.byType(SmartEntryPreviewRowCard), findsNWidgets(2));
    expect(_text(_titleMany(2)), findsOneWidget);
    expect(_text(_confirmMany(2)), findsOneWidget);
  });

  testWidgets('a single row uses the singular wording', (tester) async {
    await _open(tester, _state([_valid]));

    expect(find.byType(SmartEntryPreviewRowCard), findsOneWidget);
    expect(_text(_confirmOne), findsOneWidget);
    expect(_text(_titleMany(2)), findsNothing);
  });

  testWidgets('rows can only be removed while there is more than one', (
    tester,
  ) async {
    final state = _state([_valid, _valid]);
    await _open(tester, state);

    final firstCardRemove = find.descendant(
      of: find.byType(SmartEntryPreviewRowCard).first,
      matching: find.byType(CcCancelBtn),
    );
    await tester.tap(firstCardRemove);
    await tester.pumpAndSettle();
    await _flushDebounce(tester);

    expect(state.rows, hasLength(1));
    expect(find.byType(SmartEntryPreviewRowCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SmartEntryPreviewRowCard),
        matching: find.byType(CcCancelBtn),
      ),
      findsNothing,
    );
  });

  testWidgets('typing in the amount field edits that row', (tester) async {
    final state = _state([_valid]);
    await _open(tester, state);

    await tester.enterText(find.byType(TextField).first, '2500');
    await tester.pump();

    expect(state.rows.single.amount, 2500);
  });

  testWidgets('typing in the note field edits that row', (tester) async {
    final state = _state([_valid]);
    await _open(tester, state);

    await tester.enterText(find.byType(TextField).last, 'Bun cha');
    await tester.pump();

    expect(state.rows.single.note, 'Bun cha');
  });

  testWidgets('confirm is blocked until every row is valid', (tester) async {
    final state = _state([
      const ParsedTransactionEntity(categoryId: 'food', note: 'no amount'),
    ]);
    SmartEntryCommitResult? sent;
    var calls = 0;
    await _open(
      tester,
      state,
      onConfirm: (rows) async {
        calls++;
        sent = SmartEntryCommitResult(saved: rows.length);
        return sent!;
      },
    );

    await _tapConfirm(tester);
    expect(calls, 0);
    expect(find.byType(SmartEntryPreviewSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '2500');
    await tester.pump();
    await _tapConfirm(tester);

    expect(calls, 1);
    expect(sent!.saved, 1);
  });

  testWidgets('confirming hands over the edited rows and closes the sheet', (
    tester,
  ) async {
    List<ParsedTransactionEntity>? received;
    await _open(
      tester,
      _state([_valid, _valid]),
      onConfirm: (rows) async {
        received = rows;
        return SmartEntryCommitResult(saved: rows.length);
      },
    );
    await tester.enterText(find.byType(TextField).first, '70000');
    await tester.pump();

    await _tapConfirm(tester);

    expect(received!.map((e) => e.amount), [70000, 50000]);
    expect(find.byType(SmartEntryPreviewSheet), findsNothing);
  });

  testWidgets('a partial save keeps only the unsaved rows and shows why', (
    tester,
  ) async {
    final state = _state([
      _valid,
      const ParsedTransactionEntity(
        amount: 99000,
        categoryId: 'food',
        note: 'second',
      ),
    ]);
    await _open(
      tester,
      state,
      onConfirm: (_) async =>
          const SmartEntryCommitResult(saved: 1, error: 'second one failed'),
    );

    await _tapConfirm(tester);

    expect(find.byType(SmartEntryPreviewSheet), findsOneWidget);
    expect(find.byType(SmartEntryPreviewRowCard), findsOneWidget);
    expect(state.rows.single.note, 'second');
    expect(_text('second one failed'), findsOneWidget);
  });

  testWidgets('a total failure keeps every row and shows the error', (
    tester,
  ) async {
    final state = _state([_valid, _valid]);
    await _open(
      tester,
      state,
      onConfirm: (_) async =>
          const SmartEntryCommitResult(saved: 0, error: 'nothing saved'),
    );

    await _tapConfirm(tester);

    expect(state.rows, hasLength(2));
    expect(_text('nothing saved'), findsOneWidget);
  });

  const screens = {
    'small mobile': Size(320, 640),
    'mobile': Size(390, 844),
    'tablet': Size(768, 1024),
    'desktop': Size(1280, 800),
    'mobile landscape': Size(844, 390),
    'small mobile landscape': Size(640, 320),
  };
  for (final screen in screens.entries) {
    testWidgets('lays out without overflow on ${screen.key}', (tester) async {
      final state = _state([_valid, _valid, _valid], mixed: true);
      await _open(tester, state, logicalSize: screen.value);

      expect(tester.takeException(), isNull);
      expect(find.byType(SmartEntryPreviewRowCard), findsWidgets);
      expect(find.byType(CcBaseBtn), findsOneWidget);
    });
  }

  testWidgets('keeps working when the keyboard covers half the screen', (
    tester,
  ) async {
    final state = _state([_valid, _valid], mixed: true);
    await _open(tester, state, logicalSize: const Size(390, 844));
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CcBaseBtn), findsOneWidget);
  });

  testWidgets('the type toggle only exists for a mixed scope', (tester) async {
    await _open(tester, _state([_valid]));
    expect(_text(_income), findsNothing);
  });

  testWidgets('switching a row to income clears its expense category', (
    tester,
  ) async {
    final state = _state([_valid], mixed: true);
    await _open(tester, state);

    await tester.tap(_text(_income).first);
    await tester.pumpAndSettle();
    await _flushDebounce(tester);

    expect(state.rows.single.type, CategoryType.income);
    expect(state.rows.single.categoryId, isEmpty);
    expect(state.canConfirm, isFalse);
  });
}
