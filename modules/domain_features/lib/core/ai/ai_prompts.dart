import '../../features/budget_limit/domain/entities/budget_anomaly_entity.dart';
import '../../features/budget_limit/domain/entities/budget_insights_entity.dart';
import '../../features/budget_limit/domain/entities/budget_limit_stats_entity.dart';
import '../../features/category/domain/entities/category_entity.dart';
import '../../features/report/domain/entities/financial_runway_entity.dart';
import '../../features/transaction/domain/usecases/get_monthly_cash_flow_usecase.dart';
import '../constant/currency_catalog.dart';
import '../constant/currency_constants.dart';
import 'smart_entry_context.dart';

abstract final class AiPrompts {
  static String smartEntryText({
    required String text,
    required SmartEntryContext context,
    required int maxTransactions,
  }) =>
      'You extract ${_kind(context)} transactions from a short free-text or '
      'dictated quick-entry string in any language (Vietnamese is the most '
      'common). '
      'Text: "$text". '
      'For each transaction extract the amount, a category id, a wallet id, '
      'the transaction date and a short note (merchant/item). '
      'Usually the text describes exactly one transaction. Never split one '
      'purchase into several transactions because of quantities or item '
      'lists (e.g. "2 ly cafe 50k" is one transaction). Return several '
      'transactions only when the text clearly describes separate payments '
      '(e.g. "an pho 50k, cafe 30k"). Return an empty array when no '
      'transaction is described. '
      '${_limitSentence(maxTransactions)} '
      '${_typeSentence(context)}'
      '${currencySentence(context.currency)} '
      '${noteLanguageSentence(context.language)} '
      '${todaySentence(context.today)} '
      'IMPORTANT: If the text contains relative dates like "hôm qua" (yesterday), '
      '"hôm kia" (the day before yesterday), or specific dates, resolve them '
      "relative to the provided today's date. "
      '${categoryOptions(context)} '
      '${walletOptions(context.wallets)}';

  static String smartEntryImages({
    required int imageCount,
    required SmartEntryContext context,
    required int maxTransactions,
  }) =>
      'You are given $imageCount ${imageCount == 1 ? 'image' : 'images'} '
      'related to ${_kind(context)} transactions. '
      'First set "documentKind". '
      '"single_receipt": one receipt, invoice, bill, payment confirmation or '
      'bank transfer screenshot. It is exactly ONE transaction at the final '
      'amount paid (after tax and discount), however many line items it '
      'lists. '
      '"transaction_list": a bank or e-wallet transaction history, a '
      'statement, an expense ledger or notebook page, or several separate '
      'receipts shown together. Every transaction row or receipt is its own '
      'transaction. '
      '"not_financial": anything else, in which case "transactions" is an '
      'empty array. '
      'For a single_receipt the note is the merchant name; when line items '
      'are shown, list them concisely like "Item1, Item2...". '
      "For a transaction_list use each row's own description as its note, "
      'skip balance and total lines, headers, promotions and rows that are '
      'pending, failed or cancelled, and resolve date headers such as '
      '"Hôm nay" or "Hôm qua" relative to today. If the same transaction '
      'appears in more than one image (overlapping screenshots), return it '
      'only once. '
      'For each transaction extract the amount, a category id, a wallet id, '
      'the transaction date if one is shown, and a short note. '
      '${_limitSentence(maxTransactions)} '
      '${_typeSentence(context)}'
      '${currencySentence(context.currency)} '
      '${noteLanguageSentence(context.language)} '
      '${todaySentence(context.today)} '
      '${categoryOptions(context)} '
      '${walletOptions(context.wallets)}';

  static String currencySentence(CurrencyDefinition currency) =>
      "The user's primary currency is ${currency.code} (${currency.symbol}). "
      'Return "amount" as the number exactly as written, in whole units of '
      'the currency it is written in, keeping any decimals (e.g. 12.5 for 12 '
      'and a half) and never converting it to another currency or to cents. '
      'Amounts with no currency written or shown are in ${currency.code}. '
      'Return "currencyCode" as the ISO 4217 code of '
      'any currency that is written or shown, by symbol, code or name '
      '(\$ is USD, € is EUR, ₩ is KRW, đ is VND, 円 is JPY, 元 is CNY, and ¥ '
      'is ${currency.code} when that is JPY or CNY, otherwise JPY), even if '
      'it is not a currency this app supports. Expand shorthand such as 50k, '
      '50 nghìn, 1,5 triệu / 1.5tr (1,500,000), 千 / 천 (1,000), 万 / 만 '
      '(10,000), 億 / 亿 / 억 (100,000,000). A "." or "," followed by exactly '
      'three digits is a thousands separator, otherwise it is a decimal '
      'separator.';

  static String noteLanguageSentence(String language) =>
      'Write "note" in $language, whatever language the input is in, but '
      'keep merchant, brand and product names as written.';

  static String todaySentence(DateTime today) {
    final iso =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    return "Today's date is $iso.";
  }

  static String categoryOptions(SmartEntryContext context) {
    if (!context.isMixed) {
      return 'Available categories (id: label): '
          '${_options(context.categories)}.';
    }
    return [
      for (final type in context.types)
        '${_typeTitle(type)} categories (id: label): ${_options(context.categories.where((c) => c.type == type))}.',
    ].join(' ');
  }

  static String walletOptions(List<AiPromptWallet> wallets) {
    if (wallets.isEmpty) return '';
    final options = wallets.map((w) => '${w.id}: ${w.name}').join(', ');
    return 'Available wallets (id: name): $options.';
  }

  static String fieldTransactions(int maxTransactions) => maxTransactions == 1
      ? 'The single most prominent transaction, or an empty array if there '
            'is none.'
      : 'Every separate transaction found, at most $maxTransactions, or an '
            'empty array if there is none.';

  static const String fieldDocumentKind =
      'What the image(s) show: one receipt/invoice/payment confirmation '
      '(single_receipt), a list of several transactions such as a bank or '
      'wallet history (transaction_list), or something unrelated '
      '(not_financial).';

  static const String fieldType =
      '"expense" for money spent, "income" for money received.';

  static String fieldAmount(CurrencyDefinition currency) =>
      'Total transaction amount in whole units of the currency it is '
      'written in (${currency.code} when none is stated), decimals '
      'allowed, never converted, or null if not determinable.';

  static const String fieldCurrencyCode =
      'ISO 4217 code of any currency written or shown in the input '
      '(even an unsupported one), or null if none is stated.';

  static const String fieldCategoryId =
      'Best-matching category id from the offered list, '
      'or null if none fits.';

  static const String fieldWalletId =
      'Best-matching wallet id from the offered list, '
      'or null if none fits.';

  static const String fieldDate =
      'Transaction date as YYYY-MM-DD, or null if not '
      'stated/shown.';

  static String fieldNote(String language) =>
      'Short note describing the purchase (merchant or '
      'item), in $language, or null.';

  static String _options(Iterable<AiPromptCategory> categories) =>
      categories.map((c) => '${c.id}: ${c.label}').join(', ');

  static String _typeTitle(String type) => switch (type) {
    CategoryType.expense => 'Expense',
    CategoryType.income => 'Income',
    CategoryType.investment => 'Investment',
    CategoryType.liability => 'Loan/debt',
    _ => type,
  };

  static String _kind(SmartEntryContext context) => context.isMixed
      ? 'personal expense or income'
      : _amountKind(context.defaultType);

  static String _limitSentence(int maxTransactions) => maxTransactions == 1
      ? 'Return only the single most prominent transaction.'
      : 'Return at most $maxTransactions transactions, in the order they '
            'appear.';

  static String _typeSentence(SmartEntryContext context) => context.isMixed
      ? 'Set "type" to "expense" for money spent or paid out (a minus sign, '
            'an outgoing transfer) and "income" for money received (a plus '
            'sign, salary, refunds, an incoming transfer), and pick '
            '"categoryId" only from the categories of that same type. '
      : '';

  static String _amountKind(String categoryType) => switch (categoryType) {
    CategoryType.income => 'personal income',
    CategoryType.investment => 'investment contribution or return',
    CategoryType.liability => 'loan/debt',
    _ => 'personal expense',
  };

  static String financialAdvice({
    required CashFlowEntity? cashFlow,
    required BudgetInsightsEntity? insights,
    required List<BudgetAnomalyEntity> anomalies,
    required FinancialRunwayEntity? runway,
    required String Function(int vndAmount) formatMoney,
    String currencyCode = CurrencyConstants.defaultCurrencyCode,
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'Bạn là một cố vấn tài chính cá nhân cho ứng dụng quản lý chi tiêu. '
        'Dựa trên dữ liệu tháng này của người dùng bên dưới, hãy trả về các '
        'phần tư vấn (sections) riêng biệt, mỗi phần có "status" là good, '
        'normal hoặc bad, và "text" là nội dung ngắn gọn (1-3 câu) bằng '
        'tiếng Việt cho phần đó, văn xuôi thuần túy (KHÔNG dùng markdown, '
        'KHÔNG dùng gạch đầu dòng, KHÔNG dùng ký hiệu *).',
      )
      ..writeln(
        'Mỗi phần cũng có "highlights" là 1-3 từ hoặc cụm từ quan trọng nhất '
        'trong "text" cần nhấn mạnh cho người dùng (số tiền, tỷ lệ %, tên '
        'danh mục, hành động chính). Phải sao chép CHÍNH XÁC từng ký tự từ '
        '"text" (cùng chính tả, cùng chữ hoa/thường), mỗi cụm tối đa 6 từ, '
        'không trùng nhau. Dùng mảng rỗng nếu không có gì đáng nhấn mạnh.',
      )
      ..writeln()
      ..writeln(
        'Chọn 2-4 phần phù hợp nhất với dữ liệu trong các loại sau (bỏ qua '
        'loại không áp dụng):',
      )
      ..writeln(
        '- Nhận xét về các khoản chi bất thường so với 3 tháng gần nhất: '
        'status="bad" nếu phát hiện bất thường, status="good" nếu không có.',
      )
      ..writeln(
        '- Nếu thu không đủ chi (thâm hụt): 1-2 chiến lược tăng thu nhập cụ '
        'thể, thực tế để bù đắp phần thâm hụt, status="bad".',
      )
      ..writeln(
        '- Gợi ý tối ưu chi tiêu và khuyến khích hành vi tài chính tích cực '
        '(tiết kiệm, chi tiêu có kế hoạch): status="normal" nếu là lời '
        'khuyên trung lập, status="good" nếu tình hình đang tốt và đây là '
        'lời khen — không tạo cảm giác lo lắng không cần thiết khi không có '
        'vấn đề gì.',
      )
      ..writeln()
      ..writeln('Tổng độ dài toàn bộ các phần khoảng 120-200 từ.')
      ..writeln()
      ..writeln(
        'Đơn vị tiền tệ của người dùng: $currencyCode. Mọi số tiền bên dưới đã '
        'được định dạng theo đơn vị này, hãy giữ nguyên ký hiệu và định dạng khi trích dẫn.',
      )
      ..writeln('Dữ liệu tháng này:');

    if (cashFlow != null) {
      final incomeStr = formatMoney(cashFlow.income);
      final expenseStr = formatMoney(cashFlow.expense);
      final debtInflowStr = formatMoney(cashFlow.debtInflow);
      final debtOutflowStr = formatMoney(cashFlow.debtOutflow);
      final investInflowStr = formatMoney(cashFlow.investmentInflow);
      final investOutflowStr = formatMoney(cashFlow.investmentOutflow);
      final opNetStr = formatMoney(cashFlow.operatingNet);
      final netStr = formatMoney(cashFlow.net);

      buffer.writeln(
        '- Thu nhập: $incomeStr. '
        'Chi tiêu: $expenseStr. '
        'Tiền vay/thu nợ vào: $debtInflowStr. '
        'Tiền cho vay/trả nợ ra: $debtOutflowStr. '
        'Lợi nhuận đầu tư vào: $investInflowStr. '
        'Vốn đầu tư ra: $investOutflowStr. '
        'Chênh lệch thu - chi: $opNetStr '
        '(${cashFlow.isDeficit ? "thâm hụt" : "dương"}). '
        'Chênh lệch dòng tiền tổng: $netStr.',
      );
      if (cashFlow.isInflowDebtDriven) {
        buffer.writeln(
          '- Lưu ý: ${cashFlow.debtInflowPercent}% tiền vào tháng này đến từ '
          'nợ (vay hoặc thu nợ), không phải thu nhập thực.',
        );
      }
      if (cashFlow.isOutflowDebtDriven) {
        buffer.writeln(
          '- Lưu ý: ${cashFlow.debtOutflowPercent}% tiền ra tháng này là cho '
          'vay hoặc trả nợ, không phải chi tiêu thông thường.',
        );
      }
    } else {
      buffer.writeln('- Không có dữ liệu thu chi tháng này.');
    }

    final pacingWarnings = insights?.pacingWarnings ?? const [];
    final penaltyWarnings = insights?.penaltyWarnings ?? const [];
    if (pacingWarnings.isEmpty && penaltyWarnings.isEmpty) {
      buffer.writeln('- Cảnh báo ngân sách: không có.');
    } else {
      buffer.writeln('- Cảnh báo ngân sách:');
      for (final w in pacingWarnings) {
        final spendStr = formatMoney(w.suggestedDailySpend);
        buffer.writeln(
          '  + ${w.budgetName}: còn ${w.daysRemaining} ngày, nên chi '
          '≤ $spendStr/ngày.',
        );
      }
      for (final w in penaltyWarnings) {
        buffer.writeln(
          '  + ${w.budgetName}: đã vượt ${_penaltyTierLabel(w.tier)} hạn mức '
          '(${w.percentUsed}% đã dùng).',
        );
      }
    }

    if (anomalies.isEmpty) {
      buffer.writeln('- Khoản chi bất thường: không có.');
    } else {
      buffer.writeln('- Khoản chi bất thường:');
      for (final a in anomalies) {
        final spendStr = formatMoney(a.thisMonthSpend);
        final avgStr = formatMoney(a.avgPrevMonths.round());
        buffer.writeln(
          '  + ${a.budgetName}: $spendStr '
          'tháng này so với trung bình '
          '$avgStr 3 tháng trước.',
        );
      }
    }

    if (runway != null) {
      final burnStr = formatMoney(runway.monthlyBurn.round());
      buffer.writeln(
        '- Chỉ số an toàn tài chính (runway): ${runway.months} tháng '
        '${runway.days} ngày (${_runwayStatusLabel(runway.status)}), chi '
        'tiêu trung bình/bắt buộc hàng tháng: '
        '$burnStr.',
      );
    } else {
      buffer.writeln('- Không có dữ liệu chỉ số an toàn tài chính.');
    }

    return buffer.toString();
  }

  static String _penaltyTierLabel(BudgetPenaltyTier tier) {
    switch (tier) {
      case BudgetPenaltyTier.tier120:
        return '120%';
      case BudgetPenaltyTier.tier150:
        return '150%';
      case BudgetPenaltyTier.tier200:
        return '200%';
      case BudgetPenaltyTier.none:
        return '';
    }
  }

  static String _runwayStatusLabel(FinancialRunwayStatus? status) {
    switch (status) {
      case FinancialRunwayStatus.excellent:
        return 'rất tốt';
      case FinancialRunwayStatus.good:
        return 'tốt';
      case FinancialRunwayStatus.safe:
        return 'an toàn';
      case FinancialRunwayStatus.caution:
        return 'cần thận trọng';
      case FinancialRunwayStatus.insufficient:
        return 'chưa đủ dữ liệu';
      case null:
        return 'chưa xác định';
    }
  }
}
