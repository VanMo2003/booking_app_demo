import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../tour/domain/entities/travel_theme.dart';
import '../entities/ai.dart';
import '../repositories/ai_repository.dart';

/// Máy chủ có bật AI không (có API key) — để ẩn các nút AI khi chưa bật.
@lazySingleton
class AiAvailability {
  AiAvailability(this._repository);

  final AiRepository _repository;

  final enabled = ValueNotifier(false);

  Future<void> refresh() async {
    try {
      enabled.value = await _repository.enabled();
    } catch (_) {
      // Mất mạng: giữ trạng thái cũ.
    }
  }
}

@injectable
class SearchWithAi {
  const SearchWithAi(this._repository);

  final AiRepository _repository;

  Future<AiSearchResult> call(String query) => _repository.search(query.trim());
}

@injectable
class SearchToursWithAi {
  const SearchToursWithAi(this._repository);

  final AiRepository _repository;

  Future<AiTourSearchResult> call(String query) => _repository.searchTours(query.trim());
}

@injectable
class PlanTripWithAi {
  const PlanTripWithAi(this._repository);

  final AiRepository _repository;

  Future<AiTripPlan> call(String query) => _repository.planTrip(query.trim());
}

@injectable
class GetReviewDigest {
  const GetReviewDigest(this._repository);

  final AiRepository _repository;

  Future<ReviewDigest> call(int hotelId) => _repository.reviewDigest(hotelId);
}

@injectable
class DraftTourWithAi {
  const DraftTourWithAi(this._repository);

  final AiRepository _repository;

  /// Gửi những gì quản lý đã nhập; ô nào để trống thì không gửi.
  Future<TourDraft> call({
    required int hotelId,
    required String name,
    String? destination,
    String? duration,
    String? departure,
    List<TravelTheme> themes = const [],
    String? notes,
  }) {
    String? some(String? value) => value == null || value.trim().isEmpty ? null : value.trim();
    return _repository.draftTour({
      'hotelId': hotelId,
      'name': name.trim(),
      if (some(destination) != null) 'destination': some(destination),
      if (some(duration) != null) 'duration': some(duration),
      if (some(departure) != null) 'departure': some(departure),
      if (themes.isNotEmpty) 'themes': themes.map((theme) => theme.value).toList(),
      if (some(notes) != null) 'notes': some(notes),
    });
  }
}

@injectable
class AskReportsWithAi {
  const AskReportsWithAi(this._repository);

  final AiRepository _repository;

  /// Đúng một trong hai: cơ sở (quản lý) hoặc chuỗi (chủ khách sạn).
  Future<AiReportAnswer> call(String query, {int? hotelId, int? hotelChainId}) => _repository.askReports({
        'query': query.trim(),
        if (hotelId != null) 'hotelId': hotelId,
        if (hotelChainId != null) 'hotelChainId': hotelChainId,
      });
}

@injectable
class GetPricingAdvice {
  const GetPricingAdvice(this._repository);

  final AiRepository _repository;

  Future<PricingAdvice> call(int hotelId) => _repository.pricingAdvice(hotelId);
}

@injectable
class AskGuestAssistant {
  const AskGuestAssistant(this._repository);

  final AiRepository _repository;

  Future<GuestAnswer> call(String query) => _repository.askAssistant(query.trim());
}

@injectable
class SuggestChatReply {
  const SuggestChatReply(this._repository);

  final AiRepository _repository;

  Future<AiSuggestion> call(int conversationId) => _repository.suggestReply(conversationId);
}

@injectable
class GetAiBranchSettings {
  const GetAiBranchSettings(this._repository);

  final AiRepository _repository;

  Future<AiBranchSettings> call(int hotelId) => _repository.settings(hotelId);
}

@injectable
class SetAiAutoReply {
  const SetAiAutoReply(this._repository);

  final AiRepository _repository;

  Future<AiBranchSettings> call(int hotelId, bool autoReply) =>
      _repository.setAutoReply(hotelId, autoReply);
}
