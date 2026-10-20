import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/presentation/widgets/growth_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dấu của phần trăm tăng giảm', () {
    expect(signedPercent(15.24), '+15,2%');
    expect(signedPercent(-8), '−8%');
    expect(signedPercent(0), '0%');
  });

  test('chú thích ghi đúng khoảng ngày của kỳ trước; kỳ trước bằng 0 thì ghi giá trị kỳ trước', () {
    Map<String, dynamic> period(String from, String to) => {'from': from, 'to': to};
    final summary = ReportModel.summary({
      'current': period('2026-10-01', '2026-10-20'),
      'previous': period('2026-09-01', '2026-09-20'),
      'revenueGrowth': 12.5,
    });

    expect(
      versusPrevious(summary, growth: summary.revenueGrowth, previousValue: '2 tr'),
      '+12,5% so với 01/09–20/09',
    );
    expect(
      versusPrevious(summary, growth: summary.bookingGrowth, previousValue: '0'),
      '01/09–20/09: 0',
    );
  });
}
