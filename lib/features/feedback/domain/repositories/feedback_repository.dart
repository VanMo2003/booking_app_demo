abstract interface class FeedbackRepository {
  Future<int> submit({
    required int bookingId,
    required int customerId,
    required int rating,
    required String comments,
  });

  /// BE chưa có API liệt kê đánh giá, nên đơn đã đánh giá được nhớ trên máy.
  bool isReviewed({required int customerId, required int bookingId});
}
