import 'package:injectable/injectable.dart';

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
class IsBookingReviewed {
  const IsBookingReviewed(this._repository);

  final FeedbackRepository _repository;

  bool call({required int customerId, required int bookingId}) =>
      _repository.isReviewed(customerId: customerId, bookingId: bookingId);
}
