import 'package:equatable/equatable.dart';

/// Một đánh giá của khách, kèm câu trả lời của cơ sở nếu đã có.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.rating,
    this.comments,
    this.reviewDate,
    this.customerName,
    this.hotelId,
    this.hotelName,
    this.bookingId,
    this.reply,
    this.replyAt,
  });

  final int id;
  final int rating;
  final String? comments;
  final DateTime? reviewDate;
  final String? customerName;
  final int? hotelId;
  final String? hotelName;
  final int? bookingId;

  /// Câu trả lời công khai của cơ sở, null khi chưa ai trả lời.
  final String? reply;
  final DateTime? replyAt;

  bool get answered => reply != null && reply!.isNotEmpty;

  @override
  List<Object?> get props =>
      [id, rating, comments, reviewDate, customerName, hotelId, hotelName, bookingId, reply, replyAt];
}
