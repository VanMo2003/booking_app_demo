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

/// Trả lời của AI về số liệu, kèm luôn KPI mà câu trả lời dựa vào để người đọc tự kiểm lại.
class AiReportAnswer extends Equatable {
  const AiReportAnswer({
    required this.question,
    required this.scope,
    this.from,
    this.to,
    this.answer,
    this.highlights = const [],
    this.suggestions = const [],
    this.notes = const [],
  });

  final String question;

  /// 'branch' hoặc 'chain'.
  final String scope;
  final DateTime? from;
  final DateTime? to;
  final String? answer;
  final List<String> highlights;
  final List<String> suggestions;
  final List<String> notes;

  @override
  List<Object?> get props => [question, scope, from, to, answer, highlights, suggestions, notes];
}

/// Nên làm gì với giá một loại phòng.
enum PricingAction {
  raise('RAISE'),
  hold('HOLD'),
  lower('LOWER');

  const PricingAction(this.value);

  final String value;

  static PricingAction parse(String? raw) {
    for (final action in values) {
      if (action.value == raw) return action;
    }
    return PricingAction.hold;
  }
}

/// Gợi ý giá cho một loại phòng, kèm đúng những con số mà kết luận dựa vào.
class PricingItem extends Equatable {
  const PricingItem({
    required this.roomTypeName,
    required this.action,
    this.roomTypeId,
    this.percent,
    this.reason,
    this.listPrice = 0,
    this.adr = 0,
    this.occupancyRate = 0,
    this.rooms = 0,
    this.suggestedPrice,
  });

  final int? roomTypeId;
  final String roomTypeName;
  final PricingAction action;

  /// Phần trăm tăng hoặc giảm; null khi giữ nguyên.
  final int? percent;
  final String? reason;
  final double listPrice;
  final double adr;
  final double occupancyRate;
  final int rooms;

  /// Giá niêm yết sau khi áp phần trăm, máy chủ tự tính; null khi giữ nguyên.
  final double? suggestedPrice;

  @override
  List<Object?> get props =>
      [roomTypeId, roomTypeName, action, percent, reason, listPrice, adr, occupancyRate, rooms, suggestedPrice];
}

/// AI tư vấn giá phòng cho một cơ sở. Chỉ là gợi ý — không đổi giá phòng nào.
class PricingAdvice extends Equatable {
  const PricingAdvice({
    required this.hotelId,
    required this.from,
    required this.to,
    this.outlookDays = 30,
    this.summary,
    this.items = const [],
    this.risks = const [],
    this.notes = const [],
  });

  final int hotelId;
  final DateTime from;
  final DateTime to;
  final int outlookDays;
  final String? summary;
  final List<PricingItem> items;
  final List<String> risks;
  final List<String> notes;

  @override
  List<Object?> get props => [hotelId, from, to, outlookDays, summary, items, risks, notes];
}

/// Một chỗ trong ứng dụng mà trợ lý gợi ý mở; target đã được máy chủ kiểm là đơn của chính khách.
class GuestLink extends Equatable {
  const GuestLink({required this.label, required this.target});

  final String label;
  final String target;

  @override
  List<Object?> get props => [label, target];
}

/// Trả lời của trợ lý riêng cho khách, viết từ chính các đơn của khách.
class GuestAnswer extends Equatable {
  const GuestAnswer({
    required this.question,
    this.answer,
    this.suggestions = const [],
    this.links = const [],
    this.notes = const [],
  });

  final String question;
  final String? answer;
  final List<String> suggestions;
  final List<GuestLink> links;
  final List<String> notes;

  @override
  List<Object?> get props => [question, answer, suggestions, links, notes];
}

/// Câu trả lời về một cơ sở, dựng từ chính hồ sơ cơ sở đó đã công bố.
class HotelAnswer extends Equatable {
  const HotelAnswer({
    required this.hotelId,
    required this.question,
    required this.answered,
    this.answer,
    this.links = const [],
    this.notes = const [],
  });

  final int hotelId;
  final String question;

  /// False khi hồ sơ cơ sở không có thông tin để trả lời — app mời khách nhắn cho cơ sở.
  final bool answered;
  final String? answer;

  /// Chỉ trỏ tới tour của chính cơ sở đó.
  final List<GuestLink> links;
  final List<String> notes;

  @override
  List<Object?> get props => [hotelId, question, answered, answer, links, notes];
}

/// Mức gấp của một cuộc trò chuyện, do AI đọc ra từ nội dung.
enum ChatUrgency {
  low('LOW'),
  normal('NORMAL'),
  high('HIGH');

  const ChatUrgency(this.value);

  final String value;

  static ChatUrgency parse(String? raw) {
    for (final urgency in values) {
      if (urgency.value == raw) return urgency;
    }
    return ChatUrgency.normal;
  }
}

/// Ghi chú ngắn về một cuộc trò chuyện dài, cho nhân viên của cơ sở.
class ChatSummary extends Equatable {
  const ChatSummary({
    required this.conversationId,
    required this.urgency,
    this.summary,
    this.openItems = const [],
    this.nextSteps = const [],
    this.waitingOnHotel = false,
    this.needsStaff = false,
    this.handoffReason,
    this.messageCount = 0,
  });

  final int conversationId;
  final ChatUrgency urgency;
  final String? summary;
  final List<String> openItems;
  final List<String> nextSteps;

  /// Khách nhắn cuối: cơ sở đang nợ một câu trả lời.
  final bool waitingOnHotel;
  final bool needsStaff;
  final String? handoffReason;
  final int messageCount;

  bool get isEmpty => messageCount == 0;

  @override
  List<Object?> get props => [
        conversationId,
        urgency,
        summary,
        openItems,
        nextSteps,
        waitingOnHotel,
        needsStaff,
        handoffReason,
        messageCount,
      ];
}

/// Khách đang khen hay phàn nàn về một chủ đề.
enum ThemeSentiment {
  good('GOOD'),
  mixed('MIXED'),
  bad('BAD');

  const ThemeSentiment(this.value);

  final String value;

  static ThemeSentiment parse(String? raw) {
    for (final sentiment in values) {
      if (sentiment.value == raw) return sentiment;
    }
    return ThemeSentiment.mixed;
  }
}

/// Một chủ đề khách nhắc nhiều trong đánh giá, kèm những cơ sở bị nhắc tới.
class ReviewTheme extends Equatable {
  const ReviewTheme({
    required this.topic,
    required this.sentiment,
    required this.note,
    this.branches = const [],
  });

  final String topic;
  final ThemeSentiment sentiment;
  final String note;
  final List<String> branches;

  @override
  List<Object?> get props => [topic, sentiment, note, branches];
}

/// Số đánh giá và điểm trung bình của một cơ sở trong kỳ.
class BranchReviews extends Equatable {
  const BranchReviews({required this.hotelId, required this.hotelName, this.reviews = 0, this.averageRating});

  final int hotelId;
  final String hotelName;
  final int reviews;
  final double? averageRating;

  @override
  List<Object?> get props => [hotelId, hotelName, reviews, averageRating];
}

/// AI đọc đánh giá của cả chuỗi: khách nói nhiều về điều gì, cơ sở nào bị nhắc.
class ReviewThemes extends Equatable {
  const ReviewThemes({
    required this.hotelChainId,
    required this.from,
    required this.to,
    this.reviewCount = 0,
    this.summary,
    this.themes = const [],
    this.actions = const [],
    this.byBranch = const [],
    this.notes = const [],
  });

  final int hotelChainId;
  final DateTime from;
  final DateTime to;
  final int reviewCount;
  final String? summary;
  final List<ReviewTheme> themes;
  final List<String> actions;
  final List<BranchReviews> byBranch;
  final List<String> notes;

  @override
  List<Object?> get props => [hotelChainId, from, to, reviewCount, summary, themes, actions, byBranch, notes];
}

/// Mức ưu tiên của một việc cần làm để hoàn thiện trang.
enum AuditPriority {
  high('HIGH'),
  medium('MEDIUM'),
  low('LOW');

  const AuditPriority(this.value);

  final String value;

  static AuditPriority parse(String? raw) {
    for (final priority in values) {
      if (priority.value == raw) return priority;
    }
    return AuditPriority.medium;
  }
}

/// Một tiêu chí hoàn thiện trang, do máy chủ đếm trên dữ liệu thật.
class AuditCheck extends Equatable {
  const AuditCheck({
    required this.key,
    required this.label,
    required this.passed,
    this.done,
    this.total,
    this.hint,
  });

  final String key;
  final String label;
  final bool passed;
  final int? done;
  final int? total;
  final String? hint;

  /// "3/5" khi tiêu chí đếm theo dòng, "đang có 2" khi chỉ đếm số lượng.
  String? get progress {
    if (total != null && total! > 0) return '$done/$total';
    if (done != null) return '$done';
    return null;
  }

  @override
  List<Object?> get props => [key, label, passed, done, total, hint];
}

/// Một việc nên làm, do AI diễn đạt từ tiêu chí chưa đạt.
class AuditItem extends Equatable {
  const AuditItem({
    required this.title,
    required this.priority,
    required this.how,
    this.why,
    this.checkKey,
  });

  final String title;
  final AuditPriority priority;
  final String how;
  final String? why;
  final String? checkKey;

  @override
  List<Object?> get props => [title, priority, how, why, checkKey];
}

/// Trang bán phòng của cơ sở hoàn thiện tới đâu.
class ContentAudit extends Equatable {
  const ContentAudit({
    required this.hotelId,
    required this.score,
    this.summary,
    this.checks = const [],
    this.items = const [],
    this.notes = const [],
  });

  final int hotelId;

  /// 0-100, tỉ lệ tiêu chí đạt — máy chủ tính, không phải AI nói.
  final int score;
  final String? summary;
  final List<AuditCheck> checks;
  final List<AuditItem> items;
  final List<String> notes;

  int get passedCount => checks.where((check) => check.passed).length;

  @override
  List<Object?> get props => [hotelId, score, summary, checks, items, notes];
}

/// Một dòng số liệu trong bản tin đầu ngày cần xử lý tới đâu.
enum BriefLevel {
  /// Cần người xử lý ngay hôm nay.
  urgent('URGENT'),

  /// Đáng để mắt, chưa gấp.
  watch('WATCH'),

  /// Không có gì phải làm.
  quiet('QUIET');

  const BriefLevel(this.value);

  final String value;

  bool get needsWork => this != BriefLevel.quiet;

  static BriefLevel parse(String? raw) {
    for (final level in values) {
      if (level.value == raw) return level;
    }
    return BriefLevel.quiet;
  }
}

/// Một dòng số liệu của hôm nay, do máy chủ đếm trên dữ liệu thật.
class BriefSignal extends Equatable {
  const BriefSignal({
    required this.key,
    required this.label,
    required this.value,
    required this.level,
    this.detail,
  });

  final String key;
  final String label;

  /// Con số đã viết sẵn thành chữ: "3 đơn", "1,2 tr đ".
  final String value;
  final BriefLevel level;
  final String? detail;

  @override
  List<Object?> get props => [key, label, value, level, detail];
}

/// Một việc nên làm, do AI xếp thứ tự và diễn đạt từ các dòng đang cần xử lý.
class BriefTask extends Equatable {
  const BriefTask({
    required this.title,
    required this.priority,
    required this.how,
    this.why,
    this.signalKey,
  });

  final String title;
  final AuditPriority priority;
  final String how;
  final String? why;
  final String? signalKey;

  @override
  List<Object?> get props => [title, priority, how, why, signalKey];
}

/// Bản tin đầu ngày của một cơ sở.
class DailyBrief extends Equatable {
  const DailyBrief({
    required this.hotelId,
    required this.date,
    this.headline,
    this.signals = const [],
    this.tasks = const [],
    this.notes = const [],
  });

  final int hotelId;
  final DateTime date;

  /// Một hai câu về hôm nay; rỗng khi máy chủ chưa bật AI.
  final String? headline;
  final List<BriefSignal> signals;
  final List<BriefTask> tasks;
  final List<String> notes;

  /// Các dòng đang cần xử lý, gấp trước — phần quản lý phải đọc.
  List<BriefSignal> get live => signals.where((signal) => signal.level.needsWork).toList()
    ..sort((a, b) => a.level.index.compareTo(b.level.index));

  List<BriefSignal> get calm => signals.where((signal) => !signal.level.needsWork).toList();

  int get urgentCount => signals.where((signal) => signal.level == BriefLevel.urgent).length;

  @override
  List<Object?> get props => [hotelId, date, headline, signals, tasks, notes];
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
