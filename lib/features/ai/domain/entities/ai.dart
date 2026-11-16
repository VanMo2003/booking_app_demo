import 'package:equatable/equatable.dart';

import '../../../tour/domain/entities/tour.dart';
import '../../../voucher/domain/entities/voucher.dart';
import '../../../tour/domain/entities/travel_theme.dart';

/// Bộ lọc AI rút ra từ câu tìm kiếm (máy chủ đã kiểm tra lại ngày, giá…).
class AiSearchFilters extends Equatable {
  const AiSearchFilters({
    this.checkin,
    this.checkout,
    this.guests,
    this.minPrice,
    this.maxPrice,
    this.areas = const [],
    this.amenities = const [],
    this.category,
  });

  final DateTime? checkin;
  final DateTime? checkout;
  final int? guests;
  final double? minPrice;
  final double? maxPrice;
  final List<String> areas;
  final List<String> amenities;
  final String? category;

  bool get hasDates => checkin != null && checkout != null;

  @override
  List<Object?> get props => [checkin, checkout, guests, minPrice, maxPrice, areas, amenities, category];
}

/// Một cơ sở khớp yêu cầu; số phòng và giá do máy chủ tính trên dữ liệu thật.
class AiHotelMatch extends Equatable {
  const AiHotelMatch({
    required this.hotelId,
    required this.name,
    required this.address,
    required this.matchingRooms,
    required this.fromPrice,
    this.category = '',
    this.rating = 0,
    this.image,
    this.matchedAmenities = const [],
  });

  final int hotelId;
  final String name;
  final String address;
  final String category;
  final double rating;
  final String? image;
  final int matchingRooms;
  final double fromPrice;
  final List<String> matchedAmenities;

  @override
  List<Object?> get props =>
      [hotelId, name, address, category, rating, image, matchingRooms, fromPrice, matchedAmenities];
}

class AiSearchResult extends Equatable {
  const AiSearchResult({
    required this.query,
    required this.filters,
    this.summary,
    this.results = const [],
    this.notes = const [],
  });

  final String query;
  final String? summary;
  final AiSearchFilters filters;
  final List<AiHotelMatch> results;
  final List<String> notes;

  @override
  List<Object?> get props => [query, summary, filters, results, notes];
}

/// Bộ lọc AI rút ra từ câu tìm tour (máy chủ đã kiểm tra lại ngày, giá…).
class AiTourFilters extends Equatable {
  const AiTourFilters({
    this.destinations = const [],
    this.themes = const [],
    this.minPrice,
    this.maxPrice,
    this.adults,
    this.children,
    this.tourDate,
    this.nights,
    this.withRooms,
    this.keywords = const [],
  });

  final List<String> destinations;
  final List<TravelTheme> themes;
  final double? minPrice;
  final double? maxPrice;
  final int? adults;
  final int? children;
  final DateTime? tourDate;
  final int? nights;
  final bool? withRooms;
  final List<String> keywords;

  int get guests => (adults ?? 0) + (children ?? 0);

  @override
  List<Object?> get props =>
      [destinations, themes, minPrice, maxPrice, adults, children, tourDate, nights, withRooms, keywords];
}

/// Kết quả tìm tour bằng câu nói: tour do máy chủ chọn trên dữ liệu thật, không phải model kể ra.
class AiTourSearchResult extends Equatable {
  const AiTourSearchResult({
    required this.query,
    required this.filters,
    this.summary,
    this.results = const [],
    this.notes = const [],
  });

  final String query;
  final String? summary;
  final AiTourFilters filters;
  final List<Tour> results;
  final List<String> notes;

  @override
  List<Object?> get props => [query, summary, filters, results, notes];
}

/// Nơi ở của chuyến đi: cơ sở và căn phòng thật còn trống cho cả kỳ nghỉ.
class TripStay extends Equatable {
  const TripStay({
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
    required this.checkin,
    required this.checkout,
    this.address = '',
    this.category = '',
    this.rating = 0,
    this.image,
    this.capacity = 0,
  });

  final int hotelId;
  final String hotelName;
  final String address;
  final String category;
  final double rating;
  final String? image;
  final int roomId;
  final String roomNumber;
  final String roomType;
  final int capacity;
  final double pricePerNight;
  final DateTime checkin;
  final DateTime checkout;

  @override
  List<Object?> get props => [
        hotelId,
        hotelName,
        address,
        category,
        rating,
        image,
        roomId,
        roomNumber,
        roomType,
        capacity,
        pricePerNight,
        checkin,
        checkout,
      ];
}

/// Một việc trong ngày; có [tourId] khi đó chính là một tour của kế hoạch.
class TripStep extends Equatable {
  const TripStep({required this.title, this.time, this.detail, this.tourId});

  final String title;
  final String? time;
  final String? detail;
  final int? tourId;

  @override
  List<Object?> get props => [title, time, detail, tourId];
}

class TripDay extends Equatable {
  const TripDay({required this.index, required this.date, this.title, this.steps = const []});

  final int index;
  final DateTime date;
  final String? title;
  final List<TripStep> steps;

  @override
  List<Object?> get props => [index, date, title, steps];
}

/// Tiền của cả chuyến, máy chủ tính từ giá phòng và giá tour thật.
class TripCost extends Equatable {
  const TripCost({
    this.rooms = 0,
    this.tours = 0,
    this.voucherDiscount,
    this.total = 0,
    this.perPerson = 0,
    this.leftOver,
  });

  final double rooms;
  final double tours;
  final double? voucherDiscount;
  final double total;
  final double perPerson;

  /// Ngân sách trừ tổng tiền; âm là vượt ngân sách.
  final double? leftOver;

  bool get overBudget => leftOver != null && leftOver! < 0;

  @override
  List<Object?> get props => [rooms, tours, voucherDiscount, total, perPerson, leftOver];
}

/// Kế hoạch chuyến đi: ngủ ở đâu, ngày nào đi tour nào, hết bao nhiêu tiền.
class AiTripPlan extends Equatable {
  const AiTripPlan({
    required this.query,
    required this.nights,
    required this.adults,
    this.children = 0,
    this.summary,
    this.destination,
    this.startDate,
    this.themes = const [],
    this.budget,
    this.stay,
    this.days = const [],
    this.tours = const [],
    this.voucher,
    this.cost = const TripCost(),
    this.notes = const [],
  });

  final String query;
  final String? summary;
  final String? destination;
  final DateTime? startDate;
  final int nights;
  final int adults;
  final int children;
  final List<TravelTheme> themes;
  final double? budget;
  final TripStay? stay;
  final List<TripDay> days;
  final List<Tour> tours;
  final Voucher? voucher;
  final TripCost cost;
  final List<String> notes;

  int get guests => adults + children;

  /// Máy chủ chưa tìm được cơ sở nào còn phòng: chỉ hiện điều AI hiểu và ghi chú.
  bool get isEmpty => stay == null || days.isEmpty;

  @override
  List<Object?> get props => [
        query,
        summary,
        destination,
        startDate,
        nights,
        adults,
        children,
        themes,
        budget,
        stay,
        days,
        tours,
        voucher,
        cost,
        notes,
      ];
}

/// Khách thường nói gì về một cơ sở, đọc ra từ chính đánh giá của cơ sở đó.
class ReviewDigest extends Equatable {
  const ReviewDigest({
    required this.hotelId,
    required this.available,
    this.summary,
    this.pros = const [],
    this.cons = const [],
    this.reviewCount = 0,
    this.averageRating = 0,
    this.ratingCounts = const [],
    this.generatedAt,
  });

  final int hotelId;

  /// Chưa đủ đánh giá, hoặc máy chủ chưa bật AI: app ẩn thẻ này đi.
  final bool available;
  final String? summary;
  final List<String> pros;
  final List<String> cons;
  final int reviewCount;
  final double averageRating;

  /// Số đánh giá theo từng mức sao; phần tử đầu là 1 sao.
  final List<int> ratingCounts;
  final DateTime? generatedAt;

  /// Số đánh giá nhiều nhất ở một mức sao — để vẽ thanh tỉ lệ.
  int get busiestRating => ratingCounts.isEmpty ? 0 : ratingCounts.reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props =>
      [hotelId, available, summary, pros, cons, reviewCount, averageRating, ratingCounts, generatedAt];
}

/// Nội dung nháp cho một tour do AI soạn; khách sạn sửa lại rồi tự lưu.
class TourDraft extends Equatable {
  const TourDraft({this.description, this.includes, this.cancellationPolicy, this.itinerary = const []});

  final String? description;
  final String? includes;
  final String? cancellationPolicy;
  final List<ItineraryStep> itinerary;

  bool get isEmpty =>
      (description ?? '').isEmpty &&
      (includes ?? '').isEmpty &&
      (cancellationPolicy ?? '').isEmpty &&
      itinerary.isEmpty;

  @override
  List<Object?> get props => [description, includes, cancellationPolicy, itinerary];
}

/// Bản nháp trả lời khách do AI soạn — chưa gửi gì cho khách.
class AiSuggestion extends Equatable {
  const AiSuggestion({
    required this.content,
    this.needsStaff = false,
    this.handoffReason,
    this.toolsUsed = const [],
  });

  final String content;
  final bool needsStaff;
  final String? handoffReason;
  final List<String> toolsUsed;

  @override
  List<Object?> get props => [content, needsStaff, handoffReason, toolsUsed];
}

class AiBranchSettings extends Equatable {
  const AiBranchSettings({
    required this.hotelId,
    required this.autoReply,
    required this.aiEnabled,
    this.autoReplyDelaySeconds = 90,
  });

  final int hotelId;
  final bool autoReply;

  /// Máy chủ có API key — không có thì mọi tính năng AI tắt.
  final bool aiEnabled;
  final int autoReplyDelaySeconds;

  @override
  List<Object?> get props => [hotelId, autoReply, aiEnabled, autoReplyDelaySeconds];
}
