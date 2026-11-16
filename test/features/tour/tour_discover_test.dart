import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/network/paged.dart';
import 'package:booking_app_mobile/core/storage/app_preferences.dart';
import 'package:booking_app_mobile/core/text/discover_strings.dart';
import 'package:booking_app_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:booking_app_mobile/features/ai/domain/usecases/ai_usecases.dart';
import 'package:booking_app_mobile/features/notification/services/app_link.dart';
import 'package:booking_app_mobile/features/tour/data/interest_store.dart';
import 'package:booking_app_mobile/features/tour/data/models/tour_booking_models.dart';
import 'package:booking_app_mobile/features/tour/data/models/tour_models.dart';
import 'package:booking_app_mobile/features/tour/domain/entities/tour.dart';
import 'package:booking_app_mobile/features/tour/domain/entities/travel_theme.dart';
import 'package:booking_app_mobile/features/tour/domain/repositories/tour_repository.dart';
import 'package:booking_app_mobile/features/tour/domain/usecases/tour_usecases.dart';
import 'package:booking_app_mobile/features/tour/presentation/discover/discover_cubits.dart';
import 'package:booking_app_mobile/features/tour/presentation/discover/tour_home_screen.dart';
import 'package:booking_app_mobile/features/tour/presentation/tour_detail_screen.dart';
import 'package:booking_app_mobile/features/voucher/data/voucher_repository.dart';
import 'package:booking_app_mobile/features/voucher/domain/entities/voucher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _tourJson({int id = 2, bool sale = true}) => {
      'id': id,
      'name': 'Food tour phố cổ buổi tối',
      'price': 450000,
      'hotelId': 6,
      'hotelName': 'Hoàn Kiếm Palace',
      'hotelAddress': '12 Hàng Bạc, Hà Nội',
      'duration': '4 giờ',
      'departure': '18:00 hằng ngày',
      'includes': 'Hướng dẫn viên, 8 món đặc sản, nước uống',
      'destination': 'Phố cổ Hà Nội',
      'themes': ['FOOD', 'CITY', 'UNKNOWN'],
      'itinerary': [
        {'time': '18:00', 'title': 'Khởi hành từ khách sạn'},
        {'time': '18:15', 'title': 'Bún chả và nem cua bể', 'description': 'Quán gần chợ Đồng Xuân.'},
      ],
      'childPrice': 250000,
      'cancellationPolicy': 'Huỷ miễn phí trước giờ khởi hành 24 giờ.',
      'featured': true,
      'discountPercent': sale ? 15 : null,
      'onSale': sale,
      'salePrice': sale ? 382500 : 450000,
      'saleChildPrice': sale ? 212500 : 250000,
      'available': true,
      'stayNights': 1,
    };

class _FakeTours implements TourRepository {
  @override
  Future<TourHome> home(List<TravelTheme> interests) async => TourModel.home({
        'featured': [_tourJson()],
        'deals': [_tourJson(id: 5)],
        'forYou': interests.isEmpty ? [] : [_tourJson(id: 8, sale: false)],
        'destinations': [
          {'destination': 'Vịnh Hạ Long, Quảng Ninh', 'tours': 2, 'fromPrice': 1290000},
        ],
      });

  @override
  Future<Paged<Tour>> search({String? query, TravelTheme? theme, double? maxPrice, int page = 0}) async =>
      const Paged.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

/// Máy chủ chưa bật AI: lối vào "Hỏi AI tìm tour" tự ẩn.
class _FakeAi implements AiRepository {
  @override
  Future<bool> enabled() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeVouchers implements VoucherRepository {
  @override
  Future<List<Voucher>> available({int? hotelId}) async => [
        VoucherModel.fromJson({
          'id': 2,
          'code': 'CHAOMUNG',
          'title': 'Giảm 10% cho đơn tour đầu tiên',
          'discountType': 'PERCENT',
          'value': 10,
          'maxDiscount': 200000,
          'startsAt': '2026-11-01',
          'endsAt': '2027-03-31',
          'hotelChainName': 'Hotel Number 1',
        }),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('TourModel – phần khám phá', () {
    test('đọc điểm đến, chủ đề, lịch trình, giá trẻ em và khuyến mãi', () {
      final tour = TourModel.fromJson(_tourJson());

      expect(tour.destination, 'Phố cổ Hà Nội');
      // chủ đề lạ bị bỏ qua
      expect(tour.themes, [TravelTheme.food, TravelTheme.city]);
      expect(tour.itinerary, hasLength(2));
      expect(tour.itinerary.last.description, 'Quán gần chợ Đồng Xuân.');
      expect(tour.onSale, isTrue);
      expect(tour.salePrice, 382500);
      expect(tour.childPayPrice, 212500);
      expect(tour.hotelName, 'Hoàn Kiếm Palace');
    });

    test('không khuyến mãi, không giá trẻ em: trẻ em trả như người lớn', () {
      final tour = TourModel.fromJson({'id': 1, 'name': 'Tour', 'price': 300000, 'hotelId': 6});

      expect(tour.onSale, isFalse);
      expect(tour.salePrice, 300000);
      expect(tour.childPayPrice, 300000);
      expect(tour.themes, isEmpty);
    });

    test('yêu cầu đặt tour gửi trẻ em và mã giảm giá', () {
      final json = TourBookingRequest(
        tourId: 2,
        tourDate: DateTime(2026, 12, 1),
        guests: 3,
        children: 1,
        voucherCode: ' CHAOMUNG ',
      ).toJson();

      expect(json['guests'], 3);
      expect(json['children'], 1);
      expect(json['voucherCode'], 'CHAOMUNG');
    });

    test('deep link tour và đơn phòng', () {
      expect(AppLink.parse('bookingapp://tours/2'), const TourLink(2));
      expect(AppLink.parse('bookingapp://bookings/26'), const BookingLink(26));
    });
  });

  testWidgets('chi tiết tour: giá người lớn / trẻ em, lịch trình, bao gồm, điều khoản huỷ', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: TourDetailScreen(tour: TourModel.fromJson(_tourJson()))));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Phố cổ Hà Nội'), findsOneWidget);
    expect(find.text(DiscoverStrings.salePercent(15)), findsWidgets);
    expect(find.text('212.500 ₫'), findsOneWidget);
    expect(find.text('Bún chả và nem cua bể'), findsOneWidget);
    expect(find.text('8 món đặc sản'), findsOneWidget);
    expect(find.text('Huỷ miễn phí trước giờ khởi hành 24 giờ.'), findsOneWidget);
    expect(find.byTooltip(DiscoverStrings.share), findsOneWidget);
  });

  group('trang chủ', () {
    late InterestStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'travel_interests': ['FOOD'],
        'travel_interests_asked': 1,
      });
      store = InterestStore(AppPreferences(await SharedPreferences.getInstance()), Dio());
      getIt
        ..registerSingleton<AiAvailability>(AiAvailability(_FakeAi()))
        ..registerSingleton<InterestStore>(store)
        ..registerFactory<TourHomeCubit>(() => TourHomeCubit(GetTourHome(_FakeTours()), store, _FakeVouchers()));
    });

    tearDown(() => getIt.reset());

    testWidgets('điểm đến, mã giảm giá, nổi bật, khuyến mãi và gợi ý theo sở thích', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TourHomeScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(DiscoverStrings.homeHeadline), findsOneWidget);
      expect(find.text('Vịnh Hạ Long, Quảng Ninh'), findsOneWidget);
      expect(find.text('CHAOMUNG'), findsOneWidget);
      expect(find.text(DiscoverStrings.featured), findsOneWidget);
      expect(find.text(DiscoverStrings.deals), findsOneWidget);
      expect(find.text(DiscoverStrings.forYou), findsOneWidget);
      expect(find.text(DiscoverStrings.forYouNote('Ẩm thực')), findsOneWidget);
    });

    test('sở thích lưu trên máy và đánh dấu đã hỏi', () async {
      await store.save([TravelTheme.beach, TravelTheme.mountain], sync: false);

      expect(store.interests, [TravelTheme.beach, TravelTheme.mountain]);
      expect(store.asked, isTrue);
    });
  });
}
