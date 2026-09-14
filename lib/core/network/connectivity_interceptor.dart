import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'network_status.dart';

/// Request không tới được máy chủ: kiểm tra thiết bị còn mạng không để tách
/// "mất mạng" khỏi "máy chủ không phản hồi" (BE chưa chạy, sập).
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._network);

  final NetworkStatus _network;

  static const _transportErrors = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.unknown,
  };

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final transportFailure =
        err.response == null && _transportErrors.contains(err.type);
    if (transportFailure && !await _network.isOnline()) {
      return handler.next(err.copyWith(error: const NoInternetException()));
    }
    handler.next(err);
  }
}
