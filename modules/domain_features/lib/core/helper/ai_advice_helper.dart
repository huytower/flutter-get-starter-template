import '../../features/budget_limit/domain/entities/budget_insights_entity.dart';
import '../../features/budget_limit/domain/entities/budget_limit_stats_entity.dart';
import '../../features/budget_limit/domain/usecases/get_budget_anomalies_usecase.dart';
import '../../features/report/domain/entities/financial_runway_entity.dart';
import '../../features/transaction/domain/usecases/get_month_to_date_cash_flow_usecase.dart';
import 'money_format_helper.dart';

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
/// locally (no invented figures) and forbids markdown, since no UI layer
/// here renders it.
String buildAiFinancialAdvicePrompt({
  required CashFlowEntity? cashFlow,
  required BudgetInsightsEntity? insights,
  required List<BudgetAnomalyEntity> anomalies,
  required FinancialRunwayEntity? runway,
}) {
  final buffer = StringBuffer()
    ..writeln(
      'Bạn là một cố vấn tài chính cá nhân cho ứng dụng quản lý chi tiêu. '
      'Dựa trên dữ liệu tháng này của người dùng bên dưới, hãy viết một '
      'đoạn tư vấn gồm: (1) nhận xét về các khoản chi bất thường so với '
      '3 tháng gần nhất nếu có; (2) nếu thu không đủ chi (thâm hụt), đề '
      'xuất 1-2 chiến lược tăng thu nhập cụ thể, thực tế và các việc nên '
      'làm để bù đắp phần thâm hụt; (3) đưa ra 2-3 gợi ý tối ưu chi tiêu, '
      'cảnh báo ngắn gọn nếu có thói quen chi tiêu không lành mạnh, và '
      'khuyến khích các hành vi tài chính tích cực (tiết kiệm, chi tiêu '
      'có kế hoạch). Nếu tình hình đang tốt, hãy khen ngợi ngắn gọn và '
      'gợi ý duy trì/tối ưu thêm — không tạo cảm giác lo lắng không cần '
      'thiết khi không có vấn đề gì.',
    )
    ..writeln()
    ..writeln('Dữ liệu tháng này:');

  if (cashFlow != null) {
    buffer.writeln(
      '- Thu nhập: ${formatVndWithSymbol(cashFlow.income)}. '
      'Chi tiêu: ${formatVndWithSymbol(cashFlow.expense)}. '
      'Chênh lệch: ${formatVndWithSymbol(cashFlow.net)} '
      '(${cashFlow.isDeficit ? "thâm hụt" : "dương"}).',
    );
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
      buffer.writeln(
        '  + ${w.budgetName}: còn ${w.daysRemaining} ngày, nên chi '
        '≤ ${formatVndWithSymbol(w.suggestedDailySpend)}/ngày.',
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
      buffer.writeln(
        '  + ${a.budgetName}: ${formatVndWithSymbol(a.thisMonthSpend)} '
        'tháng này so với trung bình '
        '${formatVndWithSymbol(a.avgPrevMonths.round())} 3 tháng trước.',
      );
    }
  }

  if (runway != null) {
    buffer.writeln(
      '- Chỉ số an toàn tài chính (runway): ${runway.months} tháng '
      '${runway.days} ngày (${_runwayStatusLabel(runway.status)}), chi '
      'tiêu trung bình/bắt buộc hàng tháng: '
      '${formatVndWithSymbol(runway.monthlyBurn.round())}.',
    );
  } else {
    buffer.writeln('- Không có dữ liệu chỉ số an toàn tài chính.');
  }

  buffer.writeln();
  buffer.writeln(
    'Yêu cầu định dạng: trả lời bằng tiếng Việt, văn xuôi thuần túy '
    '(KHÔNG dùng markdown, KHÔNG dùng gạch đầu dòng, KHÔNG dùng ký hiệu '
    '*), độ dài khoảng 120-200 từ.',
  );

  return buffer.toString();
}

/// Feeds the "Tạo lúc X trước" label — pure so the widget layer can format
/// it without needing `DateTime.now()` baked into a non-testable getter.
Duration timeSinceGenerated(DateTime generatedAt, {DateTime? now}) {
  return (now ?? DateTime.now()).difference(generatedAt);
}
