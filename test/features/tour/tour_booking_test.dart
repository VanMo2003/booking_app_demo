import 'package:booking_app_mobile/core/enums/app_enums.dart';
import 'package:booking_app_mobile/features/notification/services/app_link.dart';
import 'package:booking_app_mobile/features/tour/data/models/tour_booking_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TourBookingModel', () {
    test('đọc đơn trợ lý AI lên trong chat', () {
      final booking = TourBookingModel.fromJson({
        'id': 12,
        'tourId': 3,
        'tourName': 'Vịnh Hạ Long 1 ngày',
        'tourDeparture': '7:30 hằng ngày',
        'hotelId': 6,
        'hotelName': 'Khách Sạn Hoàn Kiếm Palace',
        'customerName': 'Pham Xuan Van',
        'conversationId': 4,
        'tourDate': '2026-10-18',
        'guests': 2,
        'unitPrice': 1290000.00,
        'totalAmount': 2580000.00,
        'status': 'PENDING',
        'createdByAi': true,
      });
      expect(booking.tourDate, DateTime(2026, 10, 18));
      expect(booking.totalAmount, 2580000);
      expect(booking.status, TourBookingStatus.pending);
      expect(booking.status.isOpen, isTrue);
      expect(booking.createdByAi, isTrue);
      expect(booking.conversationId, 4);
    });

    test('đơn khách sạn huỷ, tour đã bị gỡ', () {
      final booking = TourBookingModel.fromJson({
        'id': 13,
        'tourName': 'Mộc Châu săn mây',
        'hotelId': 8,
        'tourDate': '2026-11-01',
        'guests': 3,
        'unitPrice': 1690000,
        'totalAmount': 5070000,
        'status': 'CANCELED',
        'canceledBy': 'HOTEL',
        'cancelReason': 'Thời tiết xấu',
      });
      expect(booking.tourId, isNull);
      expect(booking.canceledByGuest, isFalse);
      expect(booking.status.isOpen, isFalse);
      expect(booking.cancelReason, 'Thời tiết xấu');
    });
  });

  test('deep link đơn tour từ thông báo', () {
    expect(AppLink.parse('bookingapp://tour-bookings/12'), const TourBookingLink(12));
    expect(AppLink.parse('bookingapp://tour-bookings/abc'), isNull);
  });
}
