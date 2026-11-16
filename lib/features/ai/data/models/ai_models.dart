import '../../../../core/network/json_reader.dart';
import '../../../tour/data/models/tour_models.dart';
import '../../../tour/domain/entities/travel_theme.dart';
import '../../../voucher/data/voucher_repository.dart';
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

  static AiTourSearchResult tourSearchResult(Json json) {
    final filters = json.obj('filters') ?? const <String, dynamic>{};
    return AiTourSearchResult(
      query: json.str('query'),
      summary: json.strOrNull('summary'),
      filters: AiTourFilters(
        destinations: filters.strings('destinations'),
        themes: filters.strings('themes').map(TravelTheme.tryParse).nonNulls.toList(),
        minPrice: filters['minPrice'] == null ? null : filters.decimal('minPrice'),
        maxPrice: filters['maxPrice'] == null ? null : filters.decimal('maxPrice'),
        adults: filters.intOrNull('adults'),
        children: filters.intOrNull('children'),
        tourDate: filters.date('tourDate'),
        nights: filters.intOrNull('nights'),
        withRooms: filters['withRooms'] as bool?,
        keywords: filters.strings('keywords'),
      ),
      results: json.listOf('results', TourModel.fromJson),
      notes: json.strings('notes'),
    );
  }

  static AiTripPlan tripPlan(Json json) {
    final stay = json.obj('stay');
    final cost = json.obj('cost') ?? const <String, dynamic>{};
    final voucher = json.obj('voucher');
    return AiTripPlan(
      query: json.str('query'),
      summary: json.strOrNull('summary'),
      destination: json.strOrNull('destination'),
      startDate: json.date('startDate'),
      nights: json.integer('nights'),
      adults: json.integer('adults'),
      children: json.integer('children'),
      themes: json.strings('themes').map(TravelTheme.tryParse).nonNulls.toList(),
      budget: json['budget'] == null ? null : json.decimal('budget'),
      stay: stay == null ? null : _stay(stay),
      days: json.listOf('days', _day),
      tours: json.listOf('tours', TourModel.fromJson),
      voucher: voucher == null ? null : VoucherModel.fromJson(voucher),
      cost: TripCost(
        rooms: cost.decimal('rooms'),
        tours: cost.decimal('tours'),
        voucherDiscount: cost['voucherDiscount'] == null ? null : cost.decimal('voucherDiscount'),
        total: cost.decimal('total'),
        perPerson: cost.decimal('perPerson'),
        leftOver: cost['leftOver'] == null ? null : cost.decimal('leftOver'),
      ),
      notes: json.strings('notes'),
    );
  }

  static TripStay _stay(Json json) => TripStay(
        hotelId: json.integer('hotelId'),
        hotelName: json.str('hotelName'),
        address: json.str('address'),
        category: json.str('category'),
        rating: json.decimal('rating'),
        image: json.strOrNull('pathImage'),
        roomId: json.integer('roomId'),
        roomNumber: json.str('roomNumber'),
        roomType: json.str('roomType'),
        capacity: json.integer('capacity'),
        pricePerNight: json.decimal('pricePerNight'),
        checkin: json.date('checkin') ?? DateTime.now(),
        checkout: json.date('checkout') ?? DateTime.now(),
      );

  static TripDay _day(Json json) => TripDay(
        index: json.integer('index'),
        date: json.date('date') ?? DateTime.now(),
        title: json.strOrNull('title'),
        steps: json.listOf('steps', _step),
      );

  static TripStep _step(Json json) => TripStep(
        title: json.str('title'),
        time: json.strOrNull('time'),
        detail: json.strOrNull('detail'),
        tourId: json.intOrNull('tourId'),
      );

  static ReviewDigest reviewDigest(Json json) => ReviewDigest(
        hotelId: json.integer('hotelId'),
        available: json.flag('available'),
        summary: json.strOrNull('summary'),
        pros: json.strings('pros'),
        cons: json.strings('cons'),
        reviewCount: json.integer('reviewCount'),
        averageRating: json.decimal('averageRating'),
        ratingCounts: (json['ratingCounts'] as List<dynamic>? ?? const [])
            .map((value) => (value as num?)?.toInt() ?? 0)
            .toList(),
        generatedAt: json.date('generatedAt'),
      );

  static TourDraft tourDraft(Json json) => TourDraft(
        description: json.strOrNull('description'),
        includes: json.strOrNull('includes'),
        cancellationPolicy: json.strOrNull('cancellationPolicy'),
        itinerary: json.listOf('itinerary', TourModel.step),
      );

  static AiReportAnswer reportAnswer(Json json) => AiReportAnswer(
        question: json.str('question'),
        scope: json.str('scope'),
        from: json.date('from'),
        to: json.date('to'),
        answer: json.strOrNull('answer'),
        highlights: json.strings('highlights'),
        suggestions: json.strings('suggestions'),
        notes: json.strings('notes'),
      );

  static PricingAdvice pricingAdvice(Json json) => PricingAdvice(
        hotelId: json.integer('hotelId'),
        from: json.date('from') ?? DateTime.now(),
        to: json.date('to') ?? DateTime.now(),
        outlookDays: json.integer('outlookDays', 30),
        summary: json.strOrNull('summary'),
        items: json.listOf('items', _pricingItem),
        risks: json.strings('risks'),
        notes: json.strings('notes'),
      );

  static PricingItem _pricingItem(Json json) => PricingItem(
        roomTypeId: json.intOrNull('roomTypeId'),
        roomTypeName: json.str('roomTypeName'),
        action: PricingAction.parse(json.strOrNull('action')),
        percent: json.intOrNull('percent'),
        reason: json.strOrNull('reason'),
        listPrice: json.decimal('listPrice'),
        adr: json.decimal('adr'),
        occupancyRate: json.decimal('occupancyRate'),
        rooms: json.integer('rooms'),
        suggestedPrice: json['suggestedPrice'] == null ? null : json.decimal('suggestedPrice'),
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
