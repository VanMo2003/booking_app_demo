import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_api.dart';

@LazySingleton(as: FeedbackRepository)
class FeedbackRepositoryImpl implements FeedbackRepository {
  FeedbackRepositoryImpl(this._api, this._preferences);

  final FeedbackApi _api;
  final AppPreferences _preferences;

  String _key(int customerId) => '${StorageKeys.reviewedPrefix}$customerId';

  @override
  Future<int> submit({
    required int bookingId,
    required int customerId,
    required int rating,
    required String comments,
  }) async {
    final response = await _api.create({
      'bookingId': bookingId,
      'customerId': customerId,
      'rating': rating,
      'comments': comments,
      'reviewDate': Fmt.apiDate(DateTime.now()),
    });
    final id = response.json.integer('id');
    final reviewed = {..._preferences.getStringList(_key(customerId)), '$bookingId'};
    await _preferences.setStringList(_key(customerId), reviewed.toList());
    return id;
  }

  @override
  bool isReviewed({required int customerId, required int bookingId}) =>
      _preferences.getStringList(_key(customerId)).contains('$bookingId');
}
