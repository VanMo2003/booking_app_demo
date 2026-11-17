import 'package:injectable/injectable.dart';

import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/ai.dart';
import '../../domain/entities/ai_status.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_api.dart';
import '../models/ai_models.dart';

@LazySingleton(as: AiRepository)
class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._api);

  final AiApi _api;

  @override
  Future<AiStatus> status() async => (await _api.status()).parse(
        (json) => AiStatus(
          enabled: json.flag('enabled'),
          languages: json.stringMap('languages'),
        ),
      );

  @override
  Future<AiSearchResult> search(String query) async =>
      (await _api.search({'query': query})).parse(AiModels.searchResult);

  @override
  Future<AiTourSearchResult> searchTours(String query) async =>
      (await _api.searchTours({'query': query})).parse(AiModels.tourSearchResult);

  @override
  Future<AiTripPlan> planTrip(String query) async =>
      (await _api.planTrip({'query': query})).parse(AiModels.tripPlan);

  @override
  Future<ReviewDigest> reviewDigest(int hotelId) async =>
      (await _api.reviewDigest(hotelId)).parse(AiModels.reviewDigest);

  @override
  Future<TourDraft> draftTour(Map<String, dynamic> body) async =>
      (await _api.draftTour(body)).parse(AiModels.tourDraft);

  @override
  Future<AiReportAnswer> askReports(Map<String, dynamic> body) async =>
      (await _api.askReports(body)).parse(AiModels.reportAnswer);

  @override
  Future<PricingAdvice> pricingAdvice(int hotelId) async =>
      (await _api.pricingAdvice(hotelId)).parse(AiModels.pricingAdvice);

  @override
  Future<GuestAnswer> askAssistant(String query) async =>
      (await _api.askAssistant({'query': query})).parse(AiModels.guestAnswer);

  @override
  Future<ChatSummary> chatSummary(int conversationId) async =>
      (await _api.chatSummary(conversationId)).parse(AiModels.chatSummary);

  @override
  Future<ReviewThemes> reviewThemes(int hotelChainId, {required DateTime from, required DateTime to}) async =>
      (await _api.reviewThemes(hotelChainId, Fmt.apiDate(from), Fmt.apiDate(to)))
          .parse(AiModels.reviewThemes);

  @override
  Future<ReviewReplyDraft> draftReviewReply(int feedbackId) async =>
      (await _api.draftReviewReply(feedbackId)).parse(AiModels.reviewReplyDraft);

  @override
  Future<HotelTranslation> translateHotel(int hotelId, String lang) async =>
      (await _api.translateHotel(hotelId, {'lang': lang})).parse(AiModels.hotelTranslation);

  @override
  Future<PromotionAdvice> promotionAdvice(int hotelChainId) async =>
      (await _api.promotionAdvice(hotelChainId)).parse(AiModels.promotionAdvice);

  @override
  Future<HotelCompare> compareHotels(List<int> hotelIds) async =>
      (await _api.compareHotels({'hotelIds': hotelIds})).parse(AiModels.hotelCompare);

  @override
  Future<HotelAnswer> askHotel(int hotelId, String question) async =>
      (await _api.askHotel(hotelId, {'query': question})).parse(AiModels.hotelAnswer);

  @override
  Future<DailyBrief> dailyBrief(int hotelId) async =>
      (await _api.dailyBrief(hotelId)).parse(AiModels.dailyBrief);

  @override
  Future<ContentAudit> contentAudit(int hotelId) async =>
      (await _api.contentAudit(hotelId)).parse(AiModels.contentAudit);

  @override
  Future<AiSuggestion> suggestReply(int conversationId) async =>
      (await _api.suggestReply(conversationId)).parse(AiModels.suggestion);

  @override
  Future<AiBranchSettings> settings(int hotelId) async =>
      (await _api.settings(hotelId)).parse(AiModels.settings);

  @override
  Future<AiBranchSettings> setAutoReply(int hotelId, bool autoReply) async =>
      (await _api.updateSettings(hotelId, {'autoReply': autoReply})).parse(AiModels.settings);
}
