import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

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
