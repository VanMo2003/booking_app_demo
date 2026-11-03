import 'package:booking_app_mobile/core/text/report_strings.dart';
import 'package:booking_app_mobile/features/report/data/models/report_models.dart';
import 'package:booking_app_mobile/features/report/presentation/widgets/month_ratings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('điểm tháng này và cảnh báo đánh giá thấp', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: MonthRatingsCard(
              ratings: ReportModel.ratings({
                'reviews': 8,
                'averageRating': 4.1,
                'distribution': [1, 0, 1, 2, 4],
                'reviewRate': 40,
                'lowReviews': [
                  {'feedbackId': 1, 'bookingId': 2, 'hotelName': 'HK', 'customerName': 'A', 'rating': 1, 'comments': 'x'},
                  {'feedbackId': 3, 'bookingId': 4, 'hotelName': 'HK', 'customerName': 'B', 'rating': 3, 'comments': 'y'},
                ],
              }),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.monthRatings('4,1', 8)), findsOneWidget);
    expect(find.text(ReportStrings.lowReviewsAlert(2)), findsOneWidget);
  });
}
