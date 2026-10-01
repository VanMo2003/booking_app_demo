import 'package:booking_app_mobile/core/component/photo_picker_field.dart';
import 'package:booking_app_mobile/features/tour/data/models/tour_models.dart';
import 'package:booking_app_mobile/features/tour/presentation/widgets/tour_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TourModel', () {
    test('đọc tour đầy đủ', () {
      final tour = TourModel.fromJson({
        'id': 3,
        'name': 'Food tour phố cổ buổi tối',
        'price': 450000.00,
        'duration': '4 giờ',
        'departure': '18:00 hằng ngày',
        'includes': 'Hướng dẫn viên, 8 món ăn',
        'maxGuests': 10,
        'pathImage': 'https://images.unsplash.com/photo-1?w=1200',
        'available': true,
        'hotelId': 6,
      });
      expect(tour.price, 450000);
      expect(tour.maxGuests, 10);
      expect(tourMeta(tour), '4 giờ · 18:00 hằng ngày');
    });

    test('trường tuỳ chọn vắng mặt: không giới hạn khách, không thời lượng', () {
      final tour = TourModel.fromJson({'id': 1, 'name': 'Làng lụa Vạn Phúc', 'price': 200000, 'hotelId': 9});
      expect(tour.maxGuests, isNull);
      expect(tour.available, isTrue);
      expect(tourMeta(tour), '');
    });
  });

  group('TourRequest', () {
    test('tạo mới: không gửi maxGuests khi không giới hạn', () {
      const request = TourRequest(name: 'A', price: 100000, hotelId: 6);
      expect(request.toJson().containsKey('maxGuests'), isFalse);
      expect(request.toJson()['hotelId'], 6);
    });

    test('sửa: bỏ giới hạn khách gửi 0, xoá mô tả gửi chuỗi rỗng', () {
      const request = TourRequest(name: 'A', price: 100000);
      final json = request.toJson();
      expect(json['maxGuests'], 0);
      expect(json['description'], '');
      expect(json.containsKey('hotelId'), isFalse);
    });
  });

  group('PhotoPickerController', () {
    test('tạo mới không ảnh: không gửi pathImage', () {
      final photo = PhotoPickerController();
      expect(photo.pathForRequest, isNull);
      expect(photo.hasPhoto, isFalse);
    });

    test('ảnh link ngoài hiện trong ô link; xoá ảnh gửi chuỗi rỗng', () {
      final photo = PhotoPickerController(initialPath: 'https://example.com/a.jpg');
      expect(photo.url.text, 'https://example.com/a.jpg');
      expect(photo.pathForRequest, 'https://example.com/a.jpg');
      photo.remove();
      expect(photo.pathForRequest, '');
    });

    test('ảnh đã tải lên máy chủ: giữ nguyên thì không gửi; dán link mới thì gửi link', () {
      final photo = PhotoPickerController(initialPath: '/uploads/hotels/a.jpg');
      expect(photo.url.text, isEmpty);
      expect(photo.previewPath, '/uploads/hotels/a.jpg');
      expect(photo.pathForRequest, isNull);
      photo.url.text = 'https://example.com/b.jpg';
      expect(photo.pathForRequest, 'https://example.com/b.jpg');
      expect(photo.validateUrl('ftp://x'), isNotNull);
    });
  });
}
