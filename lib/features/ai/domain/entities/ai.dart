import 'package:equatable/equatable.dart';

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
