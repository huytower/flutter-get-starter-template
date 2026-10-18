import '../../features/budget_limit/domain/entities/budget_anomaly_entity.dart';
import '../../features/budget_limit/domain/entities/budget_insights_entity.dart';
import '../../features/budget_limit/domain/entities/budget_limit_stats_entity.dart';
import '../../features/report/domain/entities/financial_runway_entity.dart';
import '../../features/transaction/domain/usecases/get_monthly_cash_flow_usecase.dart';
import '../constant/currency_constants.dart';

String _penaltyTierLabel(BudgetPenaltyTier tier) {
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

String _runwayStatusLabel(FinancialRunwayStatus? status) {
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

/// Builds the Gemini prompt for the combined budget-issues + spending-
/// optimization advice. Grounds every claim in numbers already computed
/// locally (no invented figures). The response shape (a `sections` array of
/// `{status, text}`) is enforced separately via the `responseSchema` passed
/// to `CcGeminiHelper.generateText` — this prompt only needs to explain what
/// each section should contain and how to pick its `status`.
String buildAiFinancialAdvicePrompt({
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

/// Feeds the "Tạo lúc X trước" label — pure so the widget layer can format
/// it without needing `DateTime.now()` baked into a non-testable getter.
Duration timeSinceGenerated(DateTime generatedAt, {DateTime? now}) {
  return (now ?? DateTime.now()).difference(generatedAt);
}
