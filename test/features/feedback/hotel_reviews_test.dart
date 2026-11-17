import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/network/paged.dart';
import 'package:booking_app_mobile/core/text/review_strings.dart';
import 'package:booking_app_mobile/features/feedback/data/models/review_model.dart';
import 'package:booking_app_mobile/features/feedback/domain/entities/review.dart';
import 'package:booking_app_mobile/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:booking_app_mobile/features/feedback/domain/usecases/feedback_usecases.dart';
import 'package:booking_app_mobile/features/feedback/presentation/hotel_reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, dynamic> _reviewJson(int id, {String? reply}) => {
      'id': id,
      'bookingId': 80 + id,
      'hotelId': 6,
      'hotelName': 'Hoàn Kiếm Palace',
      'customerId': 12,
      'customerName': 'Trần Thu Hà',
      'rating': reply == null ? 2 : 5,
      'comments': reply == null ? 'Phòng ồn, nhận phòng chậm.' : 'Nhân viên dễ thương, phòng sạch.',
      'reviewDate': '2026-11-14',
      if (reply != null) 'reply': reply,
      if (reply != null) 'replyAt': '2026-11-15T09:30:00',
    };

class _FakeFeedback implements FeedbackRepository {
  _FakeFeedback(this._pages);

  final List<List<Map<String, dynamic>>> _pages;
  final List<int> askedPages = [];

  @override
  Future<Paged<Review>> byHotel({required int hotelId, int page = 0, int size = 20}) async {
    askedPages.add(page);
    final items = _pages[page].map(ReviewModel.from).toList();
    final total = _pages.fold<int>(0, (sum, rows) => sum + rows.length);
    return Paged(items: items, page: page, size: size, totalElements: total, totalPages: _pages.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('đọc đánh giá và câu trả lời của cơ sở', () {
    final plain = ReviewModel.from(_reviewJson(1));
    final answered = ReviewModel.from(_reviewJson(2, reply: 'Cảm ơn chị, bên mình đã kê lại phòng.'));

    expect(plain.rating, 2);
    expect(plain.reviewDate, DateTime(2026, 11, 14));
    expect(plain.answered, isFalse);
    expect(answered.answered, isTrue);
    expect(answered.reply, startsWith('Cảm ơn chị'));
    expect(answered.replyAt, DateTime(2026, 11, 15, 9, 30));
  });

  testWidgets('danh sách đánh giá: tổng số, câu trả lời và nút xem thêm', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final fake = _FakeFeedback([
      [_reviewJson(1), _reviewJson(2, reply: 'Cảm ơn chị đã phản hồi.')],
      [_reviewJson(3)],
    ]);
    getIt.registerFactory<HotelReviewsCubit>(() => HotelReviewsCubit(GetHotelReviews(fake)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: HotelReviewsScreen(hotelId: 6, subtitle: 'Hoàn Kiếm Palace')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(fake.askedPages, [0]);
    expect(find.text(ReviewStrings.count(3)), findsOneWidget);
    expect(find.text('Cảm ơn chị đã phản hồi.'), findsOneWidget);
    expect(find.text(ReviewStrings.replyFrom), findsOneWidget);
    // Không truyền canReply thì không có nút trả lời nào — đây là màn khách cũng xem được.
    expect(find.text(ReviewStrings.reply), findsNothing);

    await tester.tap(find.text(ReviewStrings.more));
    await tester.pumpAndSettle();

    // Trang sau được nối vào, không thay thế trang trước.
    expect(fake.askedPages, [0, 1]);
    expect(find.byType(ReviewCard), findsNWidgets(3));
    expect(find.text(ReviewStrings.more), findsNothing);
  });

  testWidgets('màn trong khu làm việc mở nút trả lời', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final fake = _FakeFeedback([
      [_reviewJson(1), _reviewJson(2, reply: 'Cảm ơn chị đã phản hồi.')],
    ]);
    getIt.registerFactory<HotelReviewsCubit>(() => HotelReviewsCubit(GetHotelReviews(fake)));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: HotelReviewsScreen(hotelId: 6, canReply: true)),
    );
    await tester.pumpAndSettle();

    // Đánh giá chưa trả lời hiện "Trả lời", đánh giá đã trả lời hiện "Sửa câu trả lời".
    expect(find.text(ReviewStrings.reply), findsOneWidget);
    expect(find.text(ReviewStrings.editReply), findsOneWidget);
  });

  test('thay một dòng sau khi trả lời, không tải lại cả danh sách', () async {
    final fake = _FakeFeedback([
      [_reviewJson(1), _reviewJson(2, reply: 'Cảm ơn chị.')],
    ]);
    final cubit = HotelReviewsCubit(GetHotelReviews(fake));
    await cubit.start(6);

    final answered = ReviewModel.from(_reviewJson(1, reply: 'Bên mình đã kiểm tra lại phòng.'));
    cubit.replaceReview(answered);

    expect(fake.askedPages, [0]);
    expect(cubit.state.data!.items.first.reply, 'Bên mình đã kiểm tra lại phòng.');
    expect(cubit.state.data!.items.last.id, 2);
    expect(cubit.state.data!.total, 2);
    await cubit.close();
  });
}
