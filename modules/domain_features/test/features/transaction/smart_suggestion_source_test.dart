import 'package:domain_features/features/category/export_category.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/presentation/get_x/expense_form_controller.dart';
import 'package:domain_features/features/transaction/presentation/get_x/income_form_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message/cc_locale_keys.dart';

class _FakeTransactionRepository implements TransactionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetCategories implements GetCategoriesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionEntity _match(
  String id, {
  String type = TransactionType.expense,
  String categoryId = 'food',
  int amount = 50000,
}) => TransactionEntity(
  id: id,
  type: type,
  amount: amount,
  category: 'Food',
  categoryId: categoryId,
  date: DateTime(2026, 9, 17),
  walletId: 'w1',
);

void main() {
  group('ExpenseFormController smart suggestion', () {
    late ExpenseFormController controller;

    setUp(() {
      controller = ExpenseFormController(
        _FakeTransactionRepository(),
        _FakeGetCategories(),
      );
    });

    test('has no active suggestion by default', () {
      expect(controller.activeSuggestion, isNull);
    });

    test('prefers merchant over bill over location', () {
      controller.merchantMatchSuggestion.value = _match('1');
      controller.billMatchSuggestion.value = _match('2');
      controller.locationMatchSuggestion.value = _match('3');
      expect(
        controller.activeSuggestion!.hintKey,
        CcLocaleKeys.transaction_merchant_match_hint,
      );

      controller.merchantMatchSuggestion.value = null;
      expect(
        controller.activeSuggestion!.hintKey,
        CcLocaleKeys.transaction_bill_match_hint,
      );

      controller.billMatchSuggestion.value = null;
      expect(
        controller.activeSuggestion!.hintKey,
        CcLocaleKeys.transaction_location_match_hint,
      );

      controller.locationMatchSuggestion.value = null;
      expect(controller.activeSuggestion, isNull);
    });

    test('dismissing the active suggestion clears the bill match', () {
      controller.billMatchSuggestion.value = _match('1');

      controller.dismissActiveSuggestion();

      expect(controller.billMatchSuggestion.value, isNull);
      expect(controller.activeSuggestion, isNull);
    });

    test('applying a bill match prefills amount and category', () async {
      final keyBefore = controller.categoryKey.value;
      controller.billMatchSuggestion.value = _match('1', amount: 1200000);

      await controller.applyActiveSuggestion();

      expect(controller.amountStr.value, '1200000');
      expect(controller.pendingPrefillCategoryId.value, 'food');
      expect(controller.categoryKey.value, keyBefore + 1);
      expect(controller.billMatchSuggestion.value, isNull);
    });
  });

  group('IncomeFormController smart suggestion', () {
    late IncomeFormController controller;

    setUp(() {
      controller = IncomeFormController(
        _FakeTransactionRepository(),
        _FakeGetCategories(),
      );
    });

    test('exposes the monthly income hint for a bill match', () {
      controller.billMatchSuggestion.value = _match(
        '1',
        type: TransactionType.income,
      );

      final suggestion = controller.activeSuggestion!;

      expect(
        suggestion.hintKey,
        CcLocaleKeys.transaction_monthly_income_match_hint,
      );
      expect(suggestion.match.id, '1');
    });

    test('dismissing the active suggestion clears it', () {
      controller.billMatchSuggestion.value = _match(
        '1',
        type: TransactionType.income,
      );

      controller.dismissActiveSuggestion();

      expect(controller.activeSuggestion, isNull);
    });

    test('applying a match prefills the amount', () async {
      controller.billMatchSuggestion.value = _match(
        '1',
        type: TransactionType.income,
        amount: 15000000,
      );

      await controller.applyActiveSuggestion();

      expect(controller.amountStr.value, '15000000');
      expect(controller.billMatchSuggestion.value, isNull);
    });

    test('clears a stale category when the suggested one is unknown', () async {
      controller.setCategory(
        const CategoryEntity(
          id: 'old',
          nameKey: 'old',
          iconCode: 0,
          groupId: 'g',
          type: CategoryType.income,
        ),
      );
      controller.billMatchSuggestion.value = _match(
        '1',
        type: TransactionType.income,
        categoryId: 'missing',
      );

      await controller.applyActiveSuggestion();

      expect(controller.selectedCategory.value, isNull);
    });
  });
}
