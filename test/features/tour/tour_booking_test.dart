import 'package:booking_app_mobile/core/enums/app_enums.dart';
import 'package:booking_app_mobile/features/notification/services/app_link.dart';
import 'package:booking_app_mobile/features/tour/data/models/tour_booking_models.dart';
import 'package:booking_app_mobile/features/tour/data/models/tour_models.dart';
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

  group('Tour kèm phòng', () {
    test('tour đọc phòng của gói và số đêm', () {
      final tour = TourModel.fromJson({
        'id': 2,
        'name': 'Food tour phố cổ buổi tối',
        'price': 450000,
        'hotelId': 6,
        'stayNights': 1,
        'rooms': [
          {'roomId': 7, 'roomNumber': '101', 'roomTypeName': 'Phòng Standard', 'capacity': 2, 'price': 600000},
          {'roomId': 8, 'roomNumber': '102', 'roomTypeName': 'Phòng Gia đình', 'capacity': 4, 'price': 1430000},
        ],
      });
      expect(tour.withRooms, isTrue);
      expect(tour.rooms.map((r) => r.roomNumber), ['101', '102']);
      expect(tour.rooms.last.capacity, 4);
    });

    test('tour cũ không có phòng: chỉ bán tour, 1 đêm', () {
      final tour = TourModel.fromJson({'id': 1, 'name': 'A', 'price': 1, 'hotelId': 6});
      expect(tour.withRooms, isFalse);
      expect(tour.stayNights, 1);
    });

    test('quản lý lưu tour: gửi số đêm và danh sách phòng (rỗng = bỏ phòng)', () {
      const request = TourRequest(name: 'A', price: 1, stayNights: 2, roomIds: []);
      expect(request.toJson()['stayNights'], 2);
      expect(request.toJson()['roomIds'], isEmpty);
    });

    test('đơn tour kèm phòng: tiền tour, tiền phòng, đơn phòng', () {
      final booking = TourBookingModel.fromJson({
        'id': 5,
        'tourName': 'Vịnh Hạ Long 1 ngày',
        'hotelId': 6,
        'tourDate': '2026-10-18',
        'guests': 2,
        'unitPrice': 1290000,
        'tourAmount': 2580000,
        'roomAmount': 2420000,
        'totalAmount': 5000000,
        'status': 'PENDING',
        'bookingId': 31,
        'stayCheckout': '2026-10-20',
        'rooms': [
          {'roomId': 12, 'roomNumber': '106', 'roomTypeName': 'Phòng Deluxe', 'capacity': 3, 'price': 1210000},
        ],
      });
      expect(booking.withRooms, isTrue);
      expect(booking.roomNumbers, '106');
      expect(booking.bookingId, 31);
      expect(booking.stayCheckout, DateTime(2026, 10, 20));
      expect(booking.tourAmount! + booking.roomAmount, booking.totalAmount);
    });

    test('khách đặt tour: gửi phòng đã chọn, bỏ ghi chú trống', () {
      final json = TourBookingRequest(
        tourId: 2,
        tourDate: DateTime(2026, 10, 18),
        guests: 3,
        roomIds: const [10, 17],
        note: '  ',
      ).toJson();
      expect(json, {'tourId': 2, 'tourDate': '2026-10-18', 'guests': 3, 'roomIds': [10, 17]});
    });
  });

  test('deep link đơn tour từ thông báo', () {
    expect(AppLink.parse('bookingapp://tour-bookings/12'), const TourBookingLink(12));
    expect(AppLink.parse('bookingapp://tour-bookings/abc'), isNull);
  });
}
