import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/app_preferences.dart';

/// BE chưa có API liệt kê quản lý của một chuỗi. Tài khoản quản lý do chủ
/// khách sạn tạo trên máy này được nhớ lại để chọn khi mở cơ sở mới.
@lazySingleton
class ManagerRegistry {
  ManagerRegistry(this._preferences);

  final AppPreferences _preferences;

  String _key(String ownerUsername) =>
      '${StorageKeys.createdManagersPrefix}$ownerUsername';

  List<String> read(String ownerUsername) =>
      _preferences.getStringList(_key(ownerUsername));

  Future<void> add(String ownerUsername, String accountId) =>
      _preferences.setStringList(
        _key(ownerUsername),
        {...read(ownerUsername), accountId}.toList(),
      );
}
