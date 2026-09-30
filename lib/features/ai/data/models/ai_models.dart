import '../../../../core/network/json_reader.dart';
import '../../domain/entities/ai.dart';

abstract final class AiModels {
  static AiSearchResult searchResult(Json json) {
    final filters = json.obj('filters') ?? const <String, dynamic>{};
    return AiSearchResult(
      query: json.str('query'),
      summary: json.strOrNull('summary'),
      filters: AiSearchFilters(
        checkin: filters.date('checkin'),
        checkout: filters.date('checkout'),
        guests: filters.intOrNull('guests'),
        minPrice: filters['minPrice'] == null ? null : filters.decimal('minPrice'),
        maxPrice: filters['maxPrice'] == null ? null : filters.decimal('maxPrice'),
        areas: filters.strings('areas'),
        amenities: filters.strings('amenities'),
        category: filters.strOrNull('category'),
      ),
      results: json.listOf('results', match),
      notes: json.strings('notes'),
    );
  }

  static AiHotelMatch match(Json json) => AiHotelMatch(
        hotelId: json.integer('hotelId'),
        name: json.str('name'),
        address: json.str('address'),
        category: json.str('category'),
        rating: json.decimal('rating'),
        image: json.strOrNull('pathImage'),
        matchingRooms: json.integer('matchingRooms'),
        fromPrice: json.decimal('fromPrice'),
        matchedAmenities: json.strings('matchedAmenities'),
      );

  static AiSuggestion suggestion(Json json) => AiSuggestion(
        content: json.str('content'),
        needsStaff: json.flag('needsStaff'),
        handoffReason: json.strOrNull('handoffReason'),
        toolsUsed: json.strings('toolsUsed'),
      );

  static AiBranchSettings settings(Json json) => AiBranchSettings(
        hotelId: json.integer('hotelId'),
        autoReply: json.flag('autoReply'),
        aiEnabled: json.flag('aiEnabled'),
        autoReplyDelaySeconds: json.integer('autoReplyDelaySeconds', 90),
      );
}
