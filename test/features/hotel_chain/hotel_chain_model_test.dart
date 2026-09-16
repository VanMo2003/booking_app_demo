import 'package:booking_app_mobile/core/enums/app_enums.dart';
import 'package:booking_app_mobile/features/hotel_chain/data/models/hotel_chain_models.dart';
import 'package:booking_app_mobile/features/hotel_chain/domain/entities/hotel_chain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HotelChainModel', () {
    test('đọc trạng thái duyệt và thông tin hồ sơ', () {
      final chain = HotelChainModel.fromJson({
        'id': 7,
        'name': 'Khách sạn Sông Hàn',
        'accountId': 'acc-1',
        'ownerUsername': 'owner_flow',
        'ownerName': 'Nguyễn Văn Chủ',
        'email': 'owner@example.com',
        'phone': '0901234567',
        'address': 'Đà Nẵng',
        'approvalStatus': 'REJECTED',
        'rejectionReason': 'Số điện thoại không liên lạc được',
        'submittedAt': '2026-09-15T03:30:00.000+00:00',
      });
      expect(chain.approvalStatus, ApprovalStatus.rejected);
      expect(chain.isApproved, isFalse);
      expect(chain.ownerUsername, 'owner_flow');
      expect(chain.rejectionReason, 'Số điện thoại không liên lạc được');
      expect(chain.submittedAt, isNotNull);
    });

    test('chuỗi tạo trước khi có quy trình duyệt được coi là đã duyệt', () {
      final chain = HotelChainModel.fromJson({'id': 1, 'name': 'Chuỗi cũ'});
      expect(chain.approvalStatus, ApprovalStatus.approved);
      expect(chain.isApproved, isTrue);
    });

    test('lưu vào phiên rồi đọc lại vẫn giữ nguyên hồ sơ', () {
      const chain = HotelChain(
        id: 3,
        name: 'Khách sạn A',
        ownerName: 'Người B',
        email: 'b@example.com',
        phone: '0912345678',
        address: 'Hà Nội',
        approvalStatus: ApprovalStatus.pending,
        rejectionReason: 'Địa chỉ chưa rõ ràng',
      );
      expect(HotelChainModel.fromJson(HotelChainModel.toJson(chain)), chain);
    });

    test('hồ sơ đăng ký và yêu cầu tạo chuỗi dùng đúng khoá của BE', () {
      const profile = HotelChainProfile(
        hotelName: '  Khách sạn C ',
        address: 'Huế',
        phone: '0912345678',
        email: 'c@example.com',
        ownerName: 'Người C',
      );
      expect(profile.toJson()['hotelName'], 'Khách sạn C');
      final request = HotelChainRequest.fromProfile(profile, accountId: 'acc-9').toJson();
      expect(request['name'], 'Khách sạn C');
      expect(request['accountId'], 'acc-9');
      expect(request['email'], 'c@example.com');
    });
  });
}
