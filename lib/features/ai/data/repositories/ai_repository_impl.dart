import 'package:injectable/injectable.dart';

import '../../../../core/network/json_reader.dart';
import '../../domain/entities/ai.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_api.dart';
import '../models/ai_models.dart';

@LazySingleton(as: AiRepository)
class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._api);

  final AiApi _api;

  @override
  Future<bool> enabled() async => (await _api.status()).parse((json) => json.flag('enabled'));

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
  Future<AiSuggestion> suggestReply(int conversationId) async =>
      (await _api.suggestReply(conversationId)).parse(AiModels.suggestion);

  @override
  Future<AiBranchSettings> settings(int hotelId) async =>
      (await _api.settings(hotelId)).parse(AiModels.settings);

  @override
  Future<AiBranchSettings> setAutoReply(int hotelId, bool autoReply) async =>
      (await _api.updateSettings(hotelId, {'autoReply': autoReply})).parse(AiModels.settings);
}
