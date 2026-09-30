import '../entities/ai.dart';

abstract interface class AiRepository {
  Future<bool> enabled();

  Future<AiSearchResult> search(String query);

  Future<AiSuggestion> suggestReply(int conversationId);

  Future<AiBranchSettings> settings(int hotelId);

  Future<AiBranchSettings> setAutoReply(int hotelId, bool autoReply);
}
