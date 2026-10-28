import 'package:domain_features/core/ai/smart_entry_context.dart';
import 'package:domain_features/core/ai/smart_entry_schema.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

SmartEntryContext _context({
  List<String> types = const [CategoryType.expense],
  List<AiPromptWallet> wallets = const [(id: 'w1', name: 'Cash')],
  String primary = 'VND',
  String language = 'English',
}) => SmartEntryContext(
  types: types,
  categories: const [
    (id: 'food', label: 'Food', type: CategoryType.expense),
    (id: 'salary', label: 'Salary', type: CategoryType.income),
  ],
  wallets: wallets,
  currency: CurrencyCatalog.getDefinition(primary),
  language: language,
  today: DateTime(2026, 10, 26),
);

Map<dynamic, dynamic> _root(
  SmartEntryContext context, {
  bool withDocumentKind = false,
  int max = 20,
}) => SmartEntrySchema.build(
  context,
  withDocumentKind: withDocumentKind,
  maxTransactions: max,
).toJson();

Map<dynamic, dynamic> _transactions(Map<dynamic, dynamic> root) =>
    (root['properties'] as Map)['transactions'] as Map;

Map<dynamic, dynamic> _item(Map<dynamic, dynamic> root) =>
    (_transactions(root)['items'] as Map);

Map<dynamic, dynamic> _fields(Map<dynamic, dynamic> root) =>
    _item(root)['properties'] as Map;

void main() {
  const mixedTypes = [CategoryType.expense, CategoryType.income];

  group('root', () {
    test('text input exposes only the transactions array', () {
      final root = _root(_context());

      expect((root['properties'] as Map).keys, ['transactions']);
      expect(root['propertyOrdering'], ['transactions']);
    });

    test('image input classifies the document before listing rows', () {
      final root = _root(_context(), withDocumentKind: true);

      expect(root['propertyOrdering'], ['documentKind', 'transactions']);
      final kind = (root['properties'] as Map)['documentKind'] as Map;
      expect(kind['enum'], [
        SmartEntrySchema.kindSingleReceipt,
        SmartEntrySchema.kindTransactionList,
        SmartEntrySchema.kindNotFinancial,
      ]);
    });

    test('bounds the array by the requested maximum', () {
      final array = _transactions(_root(_context(), max: 7));

      expect(array['type'], 'ARRAY');
      expect(array['maxItems'], 7);
    });

    test('a single-row cap is described as the single most prominent one', () {
      final array = _transactions(_root(_context(), max: 1));

      expect(array['description'], contains('single most prominent'));
    });
  });

  group('transaction fields', () {
    test('lists the fields in the order the model should fill them', () {
      final item = _item(_root(_context()));

      expect(item['propertyOrdering'], [
        'amount',
        'currencyCode',
        'categoryId',
        'walletId',
        'date',
        'note',
      ]);
    });

    test('a single-type scope has no type field', () {
      expect(_fields(_root(_context())).containsKey('type'), isFalse);
    });

    test('a mixed scope asks for the type first, limited to its types', () {
      final root = _root(_context(types: mixedTypes));
      final type = _fields(root)['type'] as Map;

      expect(_item(root)['propertyOrdering'].first, 'type');
      expect(type['enum'], mixedTypes);
    });

    test('offers every in-scope category id', () {
      final category = _fields(
        _root(_context(types: mixedTypes)),
      )['categoryId'];

      expect((category as Map)['enum'], ['food', 'salary']);
      expect(category['nullable'], isTrue);
    });

    test('offers the wallets, and omits the field when there are none', () {
      final withWallets = _fields(_root(_context()))['walletId'] as Map;
      final without = _fields(_root(_context(wallets: const [])));

      expect(withWallets['enum'], ['w1']);
      expect(without.containsKey('walletId'), isFalse);
    });

    test(
      'currencyCode is a free string so unsupported codes can be flagged',
      () {
        final currency = _fields(_root(_context()))['currencyCode'] as Map;

        expect(currency['type'], 'STRING');
        expect(currency.containsKey('enum'), isFalse);
        expect(currency['nullable'], isTrue);
      },
    );

    test('amount is unconverted and names the primary as the default', () {
      final amount = _fields(_root(_context(primary: 'KRW')))['amount'] as Map;

      expect(amount['description'], contains('KRW when none is stated'));
      expect(amount['description'], contains('never converted'));
    });

    test('note follows the requested language', () {
      Map note(String language) =>
          _fields(_root(_context(language: language)))['note'] as Map;

      expect(note('English')['description'], contains('in English'));
      expect(note('Vietnamese')['description'], contains('in Vietnamese'));
      expect(note('English')['description'], isNot(contains('Vietnamese')));
    });
  });
}
