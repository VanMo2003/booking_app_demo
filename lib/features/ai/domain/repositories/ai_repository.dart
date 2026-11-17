import '../entities/ai.dart';

abstract interface class AiRepository {
  Future<bool> enabled();

  Future<AiSearchResult> search(String query);

  Future<AiTourSearchResult> searchTours(String query);

  Future<AiTripPlan> planTrip(String query);

  Future<ReviewDigest> reviewDigest(int hotelId);

  Future<TourDraft> draftTour(Map<String, dynamic> body);

  Future<AiReportAnswer> askReports(Map<String, dynamic> body);

  Future<PricingAdvice> pricingAdvice(int hotelId);

  Future<GuestAnswer> askAssistant(String query);

  Future<ChatSummary> chatSummary(int conversationId);

  Future<ReviewThemes> reviewThemes(int hotelChainId, {required DateTime from, required DateTime to});

  Future<ReviewReplyDraft> draftReviewReply(int feedbackId);

  Future<HotelTranslation> translateHotel(int hotelId, String lang);

  Future<PromotionAdvice> promotionAdvice(int hotelChainId);

  Future<HotelCompare> compareHotels(List<int> hotelIds);

  Future<HotelAnswer> askHotel(int hotelId, String question);

  Future<DailyBrief> dailyBrief(int hotelId);

  Future<ContentAudit> contentAudit(int hotelId);

  Future<AiSuggestion> suggestReply(int conversationId);

  Future<AiBranchSettings> settings(int hotelId);

  Future<AiBranchSettings> setAutoReply(int hotelId, bool autoReply);
}
