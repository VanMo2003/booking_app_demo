import '../../../../core/network/paged.dart';
import '../entities/review.dart';

abstract interface class FeedbackRepository {
  Future<int> submit({
    required int bookingId,
    required int customerId,
    required int rating,
    required String comments,
  });

  /// Đánh giá của một cơ sở, mới nhất trước — công khai, không cần đăng nhập.
  Future<Paged<Review>> byHotel({required int hotelId, int page = 0, int size = 20});

  /// Cơ sở trả lời công khai một đánh giá. Gửi lại sẽ thay câu trả lời cũ.
  Future<Review> reply({required int reviewId, required String reply});

  /// API liệt kê đánh giá là theo cơ sở, không theo khách, nên đơn đã đánh giá vẫn nhớ trên máy.
  bool isReviewed({required int customerId, required int bookingId});
}
