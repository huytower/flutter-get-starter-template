import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_investment_transaction_usecase.dart';
import 'package:domain_features/features/transaction/presentation/get_x/investment_form_controller.dart';
import 'package:domain_features/features/transaction/presentation/get_x/quick_entry_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Categories implements GetCategoriesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings implements GetProfileSettingsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Create implements CreateInvestmentTransactionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Guideline implements GuidelineProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QuickEntry implements QuickEntryHandler {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late InvestmentFormController form;
  final yesterday = DateTime.now().subtract(const Duration(days: 1));

  bool hasToday(DateTime date) => DateUtils.isSameDay(date, DateTime.now());

  setUp(() {
    form = InvestmentFormController(
      _Categories(),
      _Settings(),
      _Create(),
      _Guideline(),
      _QuickEntry(),
    );
    // The form has been open since yesterday.
    form.date.value = yesterday;
  });

  test('an untouched date moves on to today', () {
    form.followToday();

    expect(hasToday(form.date.value), isTrue);
  });

  test('a chosen date is kept', () {
    form.setDate(yesterday);
    form.followToday();

    expect(hasToday(form.date.value), isFalse);
  });

  test('a quick entry without a date means today', () {
    form.setParsedDate(null);

    expect(hasToday(form.date.value), isTrue);
  });

  test('a quick entry with a date uses it', () {
    final parsed = DateTime.now().subtract(const Duration(days: 3));
    form.setParsedDate(parsed);

    expect(DateUtils.isSameDay(form.date.value, parsed), isTrue);
  });
}
