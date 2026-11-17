import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../entities/review.dart';
import '../repositories/feedback_repository.dart';

@injectable
class SubmitReview {
  const SubmitReview(this._repository);

  final FeedbackRepository _repository;

  Future<int> call({
    required int bookingId,
    required int customerId,
    required int rating,
    required String comments,
  }) =>
      _repository.submit(
        bookingId: bookingId,
        customerId: customerId,
        rating: rating,
        comments: comments.trim(),
      );
}

@injectable
class GetHotelReviews {
  const GetHotelReviews(this._repository);

  final FeedbackRepository _repository;

  Future<Paged<Review>> call({required int hotelId, int page = 0, int size = 20}) =>
      _repository.byHotel(hotelId: hotelId, page: page, size: size);
}

@injectable
class ReplyToReview {
  const ReplyToReview(this._repository);

  final FeedbackRepository _repository;

  Future<Review> call({required int reviewId, required String reply}) =>
      _repository.reply(reviewId: reviewId, reply: reply.trim());
}

@injectable
class IsBookingReviewed {
  const IsBookingReviewed(this._repository);

  final FeedbackRepository _repository;

  bool call({required int customerId, required int bookingId}) =>
      _repository.isReviewed(customerId: customerId, bookingId: bookingId);
}
