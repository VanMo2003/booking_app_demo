import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Thiết bị có đang nối mạng (Wi-Fi, 4G, Ethernet…) hay không.
///
/// Chỉ phản ánh kết nối của thiết bị: có mạng mà máy chủ không phản hồi vẫn là
/// lỗi hệ thống, không phải mất mạng.
@lazySingleton
class NetworkStatus {
  NetworkStatus(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    try {
      return _hasNetwork(await _connectivity.checkConnectivity());
    } catch (_) {
      // Không đọc được trạng thái mạng — coi như có mạng để lỗi hiện là lỗi hệ thống.
      return true;
    }
  }

  /// Phát `true` khi có mạng trở lại, `false` khi mất mạng.
  /// Nền tảng không hỗ trợ theo dõi mạng thì stream chỉ im lặng, không báo lỗi.
  Stream<bool> get onChanged => _connectivity.onConnectivityChanged
      .map(_hasNetwork)
      .distinct()
      .handleError((Object _) {});

  static bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
