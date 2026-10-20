import '../../../../core/text/report_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_entities.dart';

/// 15.24 → "+15,2%", −8 → "−8%".
String signedPercent(double value) {
  final sign = value > 0
      ? '+'
      : value < 0
          ? '−'
          : '';
  return '$sign${Fmt.decimal(value.abs())}%';
}

/// Chú thích cho thẻ số liệu của kỳ [summary]: mức tăng giảm so với kỳ trước
/// (BE chọn theo lịch, ví dụ cùng ngày tháng trước), hoặc giá trị kỳ trước khi
/// kỳ trước bằng 0.
String versusPrevious(RevenueSummary summary, {required double? growth, required String previousValue}) {
  final from = Fmt.dayMonth(summary.previous.from);
  final to = Fmt.dayMonth(summary.previous.to);
  return growth == null
      ? ReportStrings.previousRangeValue(from, to, previousValue)
      : ReportStrings.versusPreviousRange(signedPercent(growth), from, to);
}
