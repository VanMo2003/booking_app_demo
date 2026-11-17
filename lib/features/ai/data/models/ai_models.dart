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

  static GuestAnswer guestAnswer(Json json) => GuestAnswer(
        question: json.str('question'),
        answer: json.strOrNull('answer'),
        suggestions: json.strings('suggestions'),
        links: json.listOf('links', _guestLink),
        notes: json.strings('notes'),
      );

  static GuestLink _guestLink(Json json) => GuestLink(
        label: json.str('label'),
        target: json.str('target'),
      );

  static ChatSummary chatSummary(Json json) => ChatSummary(
        conversationId: json.integer('conversationId'),
        urgency: ChatUrgency.parse(json.strOrNull('urgency')),
        summary: json.strOrNull('summary'),
        openItems: json.strings('openItems'),
        nextSteps: json.strings('nextSteps'),
        waitingOnHotel: json.flag('waitingOnHotel'),
        needsStaff: json.flag('needsStaff'),
        handoffReason: json.strOrNull('handoffReason'),
        messageCount: json.integer('messageCount'),
      );

  static ReviewThemes reviewThemes(Json json) => ReviewThemes(
        hotelChainId: json.integer('hotelChainId'),
        from: json.date('from') ?? DateTime.now(),
        to: json.date('to') ?? DateTime.now(),
        reviewCount: json.integer('reviewCount'),
        summary: json.strOrNull('summary'),
        themes: json.listOf('themes', _reviewTheme),
        actions: json.strings('actions'),
        byBranch: json.listOf('byBranch', _branchReviews),
        notes: json.strings('notes'),
      );

  static ReviewTheme _reviewTheme(Json json) => ReviewTheme(
        topic: json.str('topic'),
        sentiment: ThemeSentiment.parse(json.strOrNull('sentiment')),
        note: json.str('note'),
        branches: json.strings('branches'),
      );

  static BranchReviews _branchReviews(Json json) => BranchReviews(
        hotelId: json.integer('hotelId'),
        hotelName: json.str('hotelName'),
        reviews: json.integer('reviews'),
        averageRating: json['averageRating'] == null ? null : json.decimal('averageRating'),
      );

  static ContentAudit contentAudit(Json json) => ContentAudit(
        hotelId: json.integer('hotelId'),
        score: json.integer('score'),
        summary: json.strOrNull('summary'),
        checks: json.listOf('checks', _auditCheck),
        items: json.listOf('items', _auditItem),
        notes: json.strings('notes'),
      );

  static AuditCheck _auditCheck(Json json) => AuditCheck(
        key: json.str('key'),
        label: json.str('label'),
        passed: json.flag('passed'),
        done: json.intOrNull('done'),
        total: json.intOrNull('total'),
        hint: json.strOrNull('hint'),
      );

  static AuditItem _auditItem(Json json) => AuditItem(
        title: json.str('title'),
        priority: AuditPriority.parse(json.strOrNull('priority')),
        how: json.str('how'),
        why: json.strOrNull('why'),
        checkKey: json.strOrNull('checkKey'),
      );

  static DailyBrief dailyBrief(Json json) => DailyBrief(
        hotelId: json.integer('hotelId'),
        date: json.date('date') ?? DateTime.now(),
        headline: json.strOrNull('headline'),
        signals: json.listOf('signals', _briefSignal),
        tasks: json.listOf('tasks', _briefTask),
        notes: json.strings('notes'),
      );

  static BriefSignal _briefSignal(Json json) => BriefSignal(
        key: json.str('key'),
        label: json.str('label'),
        value: json.str('value'),
        level: BriefLevel.parse(json.strOrNull('level')),
        detail: json.strOrNull('detail'),
      );

  static BriefTask _briefTask(Json json) => BriefTask(
        title: json.str('title'),
        priority: AuditPriority.parse(json.strOrNull('priority')),
        how: json.str('how'),
        why: json.strOrNull('why'),
        signalKey: json.strOrNull('signalKey'),
      );

  static HotelAnswer hotelAnswer(Json json) => HotelAnswer(
        hotelId: json.integer('hotelId'),
        question: json.str('question'),
        answered: json.flag('answered'),
        answer: json.strOrNull('answer'),
        links: json.listOf('links', _guestLink),
        notes: json.strings('notes'),
      );

  static ReviewReplyDraft reviewReplyDraft(Json json) => ReviewReplyDraft(
        feedbackId: json.integer('feedbackId'),
        draft: json.str('draft'),
        rating: json.intOrNull('rating'),
        points: json.strings('points'),
        currentReply: json.strOrNull('currentReply'),
        notes: json.strings('notes'),
      );

  static HotelCompare hotelCompare(Json json) => HotelCompare(
        items: json.listOf('items', _compareItem),
        differences: json.strings('differences'),
        verdict: json.strOrNull('verdict'),
        notes: json.strings('notes'),
      );

  static CompareItem _compareItem(Json json) => CompareItem(
        hotelId: json.integer('hotelId'),
        name: json.str('name'),
        rooms: json.intOrNull('rooms') ?? 0,
        maxCapacity: json.intOrNull('maxCapacity') ?? 0,
        amenities: json.intOrNull('amenities') ?? 0,
        services: json.intOrNull('services') ?? 0,
        tours: json.intOrNull('tours') ?? 0,
        reviews: json.intOrNull('reviews') ?? 0,
        averageRating: json.decimal('averageRating'),
        category: json.strOrNull('category'),
        address: json.strOrNull('address'),
        priceFrom: json.decimalOrNull('priceFrom'),
        priceTo: json.decimalOrNull('priceTo'),
        fitFor: json.strOrNull('fitFor'),
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
