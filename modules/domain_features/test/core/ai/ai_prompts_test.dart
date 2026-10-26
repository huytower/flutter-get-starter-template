import 'package:domain_features/core/ai/ai_prompts.dart';
import 'package:domain_features/core/ai/smart_entry_context.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_anomaly_entity.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_insights_entity.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_limit_stats_entity.dart';
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:domain_features/features/report/domain/entities/financial_runway_entity.dart';
import 'package:domain_features/features/transaction/domain/usecases/get_monthly_cash_flow_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

SmartEntryContext _context({
  List<String> types = const [CategoryType.expense],
  List<AiPromptWallet> wallets = const [(id: 'w1', name: 'Cash')],
}) => SmartEntryContext(
  types: types,
  categories: const [
    (id: 'food', label: 'Food', type: CategoryType.expense),
    (id: 'fuel', label: 'Fuel', type: CategoryType.expense),
    (id: 'salary', label: 'Salary', type: CategoryType.income),
  ],
  wallets: wallets,
  currency: CurrencyCatalog.getDefinition('VND'),
  language: 'English',
  today: DateTime(2026, 10, 26),
);

const _mixed = [CategoryType.expense, CategoryType.income];

String _money(int amount) => '$amount@';

void main() {
  group('currencySentence', () {
    for (final def in CurrencyCatalog.definitions) {
      test('names ${def.code} as the primary and default currency', () {
        final sentence = AiPrompts.currencySentence(def);

        expect(sentence, contains('primary currency is ${def.code} '));
        expect(
          sentence,
          contains('no currency written or shown are in ${def.code}.'),
        );
      });
    }

    test('asks for the amount unconverted, in the currency as written', () {
      final sentence = AiPrompts.currencySentence(
        CurrencyCatalog.getDefinition('VND'),
      );

      expect(sentence, contains('exactly as written'));
      expect(sentence, contains('never converting it to another currency'));
      expect(sentence, isNot(contains('whole VND units')));
    });

    test('resolves ambiguous symbols instead of defaulting to primary', () {
      final sentence = AiPrompts.currencySentence(
        CurrencyCatalog.getDefinition('VND'),
      );

      expect(sentence, contains(r'$ is USD'));
      expect(sentence, contains('€ is EUR'));
      expect(sentence, contains('₩ is KRW'));
      expect(sentence, contains('¥ is VND when that is JPY or CNY'));
      expect(sentence, contains('otherwise JPY'));
    });

    test('covers CJK and Vietnamese magnitude shorthand', () {
      final sentence = AiPrompts.currencySentence(
        CurrencyCatalog.getDefinition('JPY'),
      );

      for (final token in ['nghìn', 'triệu', '千', '천', '万', '만', '億']) {
        expect(sentence, contains(token));
      }
    });
  });

  group('noteLanguageSentence', () {
    test('pins the note language but keeps proper names', () {
      final sentence = AiPrompts.noteLanguageSentence('English');

      expect(sentence, contains('"note" in English'));
      expect(sentence, contains('whatever language the input is in'));
      expect(sentence, contains('merchant, brand and product names'));
    });
  });

  group('todaySentence', () {
    test('zero-pads the ISO date', () {
      expect(
        AiPrompts.todaySentence(DateTime(2026, 3, 5)),
        "Today's date is 2026-03-05.",
      );
    });
  });

  group('options', () {
    test('lists a single-type scope as one id: label list', () {
      expect(
        AiPrompts.categoryOptions(_context()),
        'Available categories (id: label): food: Food, fuel: Fuel, '
        'salary: Salary.',
      );
    });

    test('splits a mixed scope into one list per type', () {
      final options = AiPrompts.categoryOptions(_context(types: _mixed));

      expect(
        options,
        'Expense categories (id: label): food: Food, fuel: Fuel. '
        'Income categories (id: label): salary: Salary.',
      );
    });

    test('lists wallets as id: name, and nothing when there are none', () {
      expect(
        AiPrompts.walletOptions(const [(id: 'w1', name: 'Cash')]),
        'Available wallets (id: name): w1: Cash.',
      );
      expect(AiPrompts.walletOptions(const []), isEmpty);
    });
  });

  group('smartEntryText', () {
    String prompt({
      String text = 'cafe 50k hôm qua',
      List<String> types = const [CategoryType.expense],
      int max = 20,
    }) => AiPrompts.smartEntryText(
      text: text,
      context: _context(types: types),
      maxTransactions: max,
    );

    test(
      'embeds the text, today, relative-date rule and both option lists',
      () {
        final result = prompt();

        expect(result, contains('Text: "cafe 50k hôm qua".'));
        expect(result, contains("Today's date is 2026-10-26."));
        expect(result, contains('"hôm qua" (yesterday)'));
        expect(result, contains('food: Food, fuel: Fuel'));
        expect(result, contains('w1: Cash'));
      },
    );

    test('keeps one purchase as one transaction but allows several', () {
      final result = prompt();

      expect(result, contains('Never split one purchase'));
      expect(result, contains('"2 ly cafe 50k" is one transaction'));
      expect(result, contains('separate payments'));
    });

    test('states the cap, and the single-row wording for a cap of one', () {
      expect(prompt(max: 12), contains('at most 12 transactions'));
      expect(
        prompt(max: 1),
        contains('Return only the single most prominent transaction.'),
      );
    });

    test('names the kind of the active tab', () {
      String kindOf(String type) => prompt(types: [type]);

      expect(kindOf(CategoryType.expense), contains('personal expense'));
      expect(kindOf(CategoryType.income), contains('personal income'));
      expect(
        kindOf(CategoryType.investment),
        contains('investment contribution or return'),
      );
      expect(kindOf(CategoryType.liability), contains('loan/debt'));
    });

    test('asks for a per-row type only when the scope is mixed', () {
      expect(prompt(), isNot(contains('Set "type"')));

      final mixed = prompt(types: _mixed);
      expect(mixed, contains('personal expense or income'));
      expect(mixed, contains('Set "type" to "expense"'));
      expect(mixed, contains('Income categories (id: label)'));
    });
  });

  group('smartEntryImages', () {
    String prompt({
      int count = 1,
      List<String> types = const [CategoryType.expense],
      int max = 20,
    }) => AiPrompts.smartEntryImages(
      imageCount: count,
      context: _context(types: types),
      maxTransactions: max,
    );

    test('separates one receipt (one transaction) from a list of many', () {
      final result = prompt();

      expect(result, contains('"single_receipt"'));
      expect(result, contains('exactly ONE transaction'));
      expect(result, contains('however many line items it lists'));
      expect(result, contains('"transaction_list"'));
      expect(result, contains('Every transaction row or receipt is its own'));
      expect(result, contains('"not_financial"'));
    });

    test(
      'tells the model to skip non-transaction rows and dedupe overlaps',
      () {
        final result = prompt(count: 2);

        expect(result, contains('skip balance and total lines'));
        expect(result, contains('pending, failed or cancelled'));
        expect(result, contains('"Hôm nay" or "Hôm qua"'));
        expect(result, contains('overlapping screenshots'));
      },
    );

    test('words the image count', () {
      expect(prompt(), contains('You are given 1 image '));
      expect(prompt(count: 3), contains('You are given 3 images '));
    });

    test('carries the cap and the mixed-type rule like the text prompt', () {
      final result = prompt(types: _mixed, max: 5);

      expect(result, contains('at most 5 transactions'));
      expect(result, contains('Set "type" to "expense"'));
    });
  });

  group('financialAdvice', () {
    test('states there is no data when every input is missing', () {
      final prompt = AiPrompts.financialAdvice(
        cashFlow: null,
        insights: null,
        anomalies: const [],
        runway: null,
        formatMoney: _money,
      );

      expect(prompt, contains('Không có dữ liệu thu chi tháng này.'));
      expect(prompt, contains('Cảnh báo ngân sách: không có.'));
      expect(prompt, contains('Khoản chi bất thường: không có.'));
      expect(prompt, contains('Không có dữ liệu chỉ số an toàn tài chính.'));
    });

    test('quotes the currency and the formatted figures it was given', () {
      final prompt = AiPrompts.financialAdvice(
        cashFlow: const CashFlowEntity(income: 20, expense: 30),
        insights: const BudgetInsightsEntity(
          pacingWarnings: [
            BudgetPacingWarning(
              budgetName: 'Cà phê',
              status: BudgetLimitStatus.nearLimit,
              daysRemaining: 12,
              suggestedDailySpend: 15,
            ),
          ],
          penaltyWarnings: [
            BudgetPenaltyWarning(
              budgetName: 'Ăn ngoài',
              percentUsed: 155,
              tier: BudgetPenaltyTier.tier150,
            ),
          ],
          isDeficit: true,
          deficitAmount: 10,
          anomalyCount: 1,
        ),
        anomalies: const [
          BudgetAnomalyEntity(
            budgetName: 'Mua sắm',
            thisMonthSpend: 7,
            avgPrevMonths: 3.4,
          ),
        ],
        runway: const FinancialRunwayEntity(
          months: 3,
          days: 14,
          message: '',
          totalBalance: 0,
          averageMonthlyExpense: 9,
          status: FinancialRunwayStatus.caution,
        ),
        formatMoney: _money,
        currencyCode: 'USD',
      );

      expect(prompt, contains('Đơn vị tiền tệ của người dùng: USD.'));
      expect(prompt, contains('Thu nhập: 20@. Chi tiêu: 30@.'));
      expect(prompt, contains('(thâm hụt)'));
      expect(prompt, contains('Cà phê: còn 12 ngày, nên chi ≤ 15@/ngày.'));
      expect(
        prompt,
        contains('Ăn ngoài: đã vượt 150% hạn mức (155% đã dùng).'),
      );
      expect(prompt, contains('Mua sắm: 7@ tháng này'));
      expect(prompt, contains('trung bình 3@ 3 tháng trước'));
      expect(prompt, contains('3 tháng 14 ngày (cần thận trọng)'));
    });
  });
}
