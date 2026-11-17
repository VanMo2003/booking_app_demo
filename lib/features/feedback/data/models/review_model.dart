import '../../../../core/network/json_reader.dart';
import '../../domain/entities/review.dart';

abstract final class ReviewModel {
  static Review from(Json json) => Review(
        id: json.integer('id'),
        rating: json.intOrNull('rating') ?? 0,
        comments: json.strOrNull('comments'),
        reviewDate: json.date('reviewDate'),
        customerName: json.strOrNull('customerName'),
        hotelId: json.intOrNull('hotelId'),
        hotelName: json.strOrNull('hotelName'),
        bookingId: json.intOrNull('bookingId'),
        reply: json.strOrNull('reply'),
        replyAt: json.dateTime('replyAt'),
      );
}
