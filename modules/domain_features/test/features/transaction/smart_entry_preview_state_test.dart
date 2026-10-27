import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:domain_features/features/transaction/domain/entities/parsed_transaction_entity.dart';
import 'package:domain_features/features/transaction/presentation/get_x/smart_entry_preview_state.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_test/flutter_test.dart';

const _food = CategoryEntity(
  id: 'food',
  nameKey: 'category.food',
  iconCode: 0,
  groupId: 'g',
);
const _fuel = CategoryEntity(
  id: 'fuel',
  nameKey: 'category.fuel',
  iconCode: 0,
  groupId: 'g',
);
const _salary = CategoryEntity(
  id: 'salary',
  nameKey: 'category.salary',
  iconCode: 0,
  groupId: 'g',
  type: CategoryType.income,
);

WalletEntity _wallet(String id) => WalletEntity(
  id: id,
  name: id,
  balance: 0,
  iconCode: 0,
  type: WalletType.cash,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final _now = DateTime(2026, 10, 26, 14, 30);

const _mixed = SmartEntryPreviewConfig(
  types: [CategoryType.expense, CategoryType.income],
  currencyCode: 'VND',
);
const _single = SmartEntryPreviewConfig(
  types: [CategoryType.expense],
  currencyCode: 'VND',
);

SmartEntryPreviewState _state(
  List<ParsedTransactionEntity> parsed, {
  SmartEntryPreviewConfig config = _mixed,
}) => SmartEntryPreviewState(
  parsed: parsed,
  categories: const [_food, _fuel, _salary],
  wallets: [_wallet('w1'), _wallet('w2')],
  config: config,
  defaultWalletId: 'w1',
  now: _now,
);

void main() {
  group('building rows', () {
    test('keeps what the model resolved', () {
      final state = _state([
        ParsedTransactionEntity(
          type: CategoryType.income,
          amount: 5000000,
          categoryId: 'salary',
          walletId: 'w2',
          date: DateTime(2026, 10, 1),
          note: 'October pay',
        ),
      ]);

      final row = state.rows.single;
      expect(row.type, CategoryType.income);
      expect(row.amount, 5000000);
      expect(row.categoryId, 'salary');
      expect(row.walletId, 'w2');
      expect(row.note, 'October pay');
      expect(row.date, DateTime(2026, 10, 1, 14, 30));
    });

    test('fills the gaps with usable defaults', () {
      final row = _state([
        const ParsedTransactionEntity(amount: 10),
      ]).rows.single;

      expect(row.type, CategoryType.expense);
      expect(row.categoryId, isEmpty);
      expect(row.walletId, 'w1');
      expect(row.date, _now);
      expect(row.note, isEmpty);
    });

    test('drops a category that does not belong to the row type', () {
      final row = _state([
        const ParsedTransactionEntity(
          type: CategoryType.expense,
          amount: 10,
          categoryId: 'salary',
        ),
      ]).rows.single;

      expect(row.categoryId, isEmpty);
    });

    test('drops an unknown wallet in favour of the default', () {
      final row = _state([
        const ParsedTransactionEntity(amount: 10, walletId: 'ghost'),
      ]).rows.single;

      expect(row.walletId, 'w1');
    });

    test('a single-type scope ignores the parsed type', () {
      final row = _state([
        const ParsedTransactionEntity(type: CategoryType.income, amount: 10),
      ], config: _single).rows.single;

      expect(row.type, CategoryType.expense);
    });

    test('gives every row its own id', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 1),
        const ParsedTransactionEntity(amount: 2),
      ]);

      expect(state.rows.map((r) => r.id).toSet(), hasLength(2));
    });
  });

  group('validity', () {
    SmartEntryPreviewState one(ParsedTransactionEntity parsed) =>
        _state([parsed]);

    test('needs an amount, a wallet and a category', () {
      final ok = one(
        const ParsedTransactionEntity(amount: 5, categoryId: 'food'),
      );
      expect(ok.canConfirm, isTrue);

      final noAmount = one(const ParsedTransactionEntity(categoryId: 'food'));
      expect(noAmount.canConfirm, isFalse);

      final noCategory = one(const ParsedTransactionEntity(amount: 5));
      expect(noCategory.canConfirm, isFalse);
    });

    test('does not need a category when the host has no category picker', () {
      final state = _state(
        [const ParsedTransactionEntity(amount: 5)],
        config: const SmartEntryPreviewConfig(
          types: [CategoryType.investment],
          currencyCode: 'VND',
          showCategory: false,
        ),
      );

      expect(state.canConfirm, isTrue);
    });

    test('every row has to be valid', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 5, categoryId: 'food'),
        const ParsedTransactionEntity(categoryId: 'food'),
      ]);

      expect(state.canConfirm, isFalse);
      expect(state.isValid(state.rows.first), isTrue);
      expect(state.isValid(state.rows.last), isFalse);
    });

    test('is false with no rows left, or while saving', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 5, categoryId: 'food'),
      ]);

      state.isCommitting.value = true;
      expect(state.canConfirm, isFalse);

      state.isCommitting.value = false;
      state.remove(state.rows.single.id);
      expect(state.canConfirm, isFalse);
    });
  });

  group('editing', () {
    test('edit changes only the targeted row', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 1),
        const ParsedTransactionEntity(amount: 2),
      ]);

      state.edit(state.rows.first.id, (row) => row.copyWith(amount: 99));

      expect(state.rows.map((r) => r.amount), [99, 2]);
    });

    test('editing an unknown id does nothing', () {
      final state = _state([const ParsedTransactionEntity(amount: 1)]);

      state.edit(999, (row) => row.copyWith(amount: 50));

      expect(state.rows.single.amount, 1);
    });

    test('switching type clears a category of the other type', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 5, categoryId: 'food'),
      ]);

      state.setType(state.rows.single.id, CategoryType.income);

      expect(state.rows.single.type, CategoryType.income);
      expect(state.rows.single.categoryId, isEmpty);
    });

    test('switching to the same type keeps the category', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 5, categoryId: 'food'),
      ]);

      state.setType(state.rows.single.id, CategoryType.expense);

      expect(state.rows.single.categoryId, 'food');
    });

    test('an edit clears a stale error message', () {
      final state = _state([const ParsedTransactionEntity(amount: 1)]);
      state.errorText.value = 'boom';

      state.edit(state.rows.single.id, (row) => row.copyWith(amount: 2));

      expect(state.errorText.value, isNull);
    });

    test('lists categories per type', () {
      final state = _state(const []);

      expect(state.categoriesFor(CategoryType.expense).map((c) => c.id), [
        'food',
        'fuel',
      ]);
      expect(state.categoriesFor(CategoryType.income).map((c) => c.id), [
        'salary',
      ]);
    });
  });

  group('removing and saving', () {
    test('remove drops the row', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 1),
        const ParsedTransactionEntity(amount: 2),
      ]);

      state.remove(state.rows.first.id);

      expect(state.rows.map((r) => r.amount), [2]);
    });

    test('dropSaved removes the rows that already went through', () {
      final state = _state([
        const ParsedTransactionEntity(amount: 1),
        const ParsedTransactionEntity(amount: 2),
        const ParsedTransactionEntity(amount: 3),
      ]);

      state.dropSaved(2);

      expect(state.rows.map((r) => r.amount), [3]);
    });

    test('dropSaved copes with zero and with more than there are', () {
      final state = _state([const ParsedTransactionEntity(amount: 1)]);

      state.dropSaved(0);
      expect(state.rows, hasLength(1));

      state.dropSaved(5);
      expect(state.rows, isEmpty);
    });
  });

  group('totals and output', () {
    test('totals each type separately', () {
      final state = _state([
        const ParsedTransactionEntity(type: CategoryType.expense, amount: 30),
        const ParsedTransactionEntity(type: CategoryType.expense, amount: 20),
        const ParsedTransactionEntity(type: CategoryType.income, amount: 100),
      ]);

      expect(state.totalFor(CategoryType.expense), 50);
      expect(state.totalFor(CategoryType.income), 100);
    });

    test('toEntities carries the edited values and trims the note', () {
      final state = _state([
        const ParsedTransactionEntity(
          type: CategoryType.income,
          amount: 7,
          categoryId: 'salary',
        ),
      ]);
      state.edit(
        state.rows.single.id,
        (row) => row.copyWith(note: '  bonus  ', amount: 9),
      );

      final out = state.toEntities().single;

      expect(out.type, CategoryType.income);
      expect(out.amount, 9);
      expect(out.categoryId, 'salary');
      expect(out.walletId, 'w1');
      expect(out.note, 'bonus');
    });

    test('toEntities turns empty strings back into nulls', () {
      final out = _state([
        const ParsedTransactionEntity(amount: 7),
      ]).toEntities().single;

      expect(out.categoryId, isNull);
      expect(out.note, isNull);
    });

    test('a single-type scope leaves the type to the host', () {
      final out = _state([
        const ParsedTransactionEntity(amount: 7),
      ], config: _single).toEntities().single;

      expect(out.type, isNull);
    });
  });
}
