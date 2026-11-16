import '../entities/ai.dart';

abstract interface class AiRepository {
  Future<bool> enabled();

  Future<AiSearchResult> search(String query);

  Future<AiTourSearchResult> searchTours(String query);

  Future<AiTripPlan> planTrip(String query);

  Future<ReviewDigest> reviewDigest(int hotelId);

  Future<TourDraft> draftTour(Map<String, dynamic> body);

  Future<AiSuggestion> suggestReply(int conversationId);

  Future<AiBranchSettings> settings(int hotelId);

  Future<AiBranchSettings> setAutoReply(int hotelId, bool autoReply);
}
