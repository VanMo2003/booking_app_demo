import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/storage/app_preferences.dart';
import '../domain/entities/favorite_hotel.dart';

/// Danh sách yêu thích lưu trên máy theo từng tài khoản.
@lazySingleton
class FavoriteStore {
  FavoriteStore(this._preferences);

  final AppPreferences _preferences;

  String _key(String username) => '${StorageKeys.favoritesPrefix}$username';

  List<FavoriteHotel> read(String username) => _preferences
      .getJsonList(_key(username))
      .map(
        (json) => FavoriteHotel(
          id: json.integer('id'),
          name: json.str('name'),
          address: json.str('address'),
          category: json.str('category'),
          rating: json.integer('rating'),
          pathImage: json.strOrNull('pathImage'),
        ),
      )
      .toList();

  Future<void> write(String username, List<FavoriteHotel> hotels) =>
      _preferences.setJsonList(
        _key(username),
        hotels
            .map(
              (hotel) => {
                'id': hotel.id,
                'name': hotel.name,
                'address': hotel.address,
                'category': hotel.category,
                'rating': hotel.rating,
                'pathImage': hotel.pathImage,
              },
            )
            .toList(),
      );
}
