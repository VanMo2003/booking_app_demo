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

/// Chú thích cho thẻ số liệu của kỳ [summary]: mức tăng giảm so với kỳ liền
/// trước cùng số ngày, hoặc giá trị kỳ trước khi kỳ trước bằng 0.
String versusPrevious(RevenueSummary summary, {required double? growth, required String previousValue}) {
  final current = summary.current;
  final days = current.to.difference(current.from).inDays + 1;
  return growth == null
      ? ReportStrings.previousDaysValue(days, previousValue)
      : ReportStrings.versusPreviousDays(signedPercent(growth), days);
}
