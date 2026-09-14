import 'package:booking_app_mobile/core/network/app_exception.dart';
import 'package:booking_app_mobile/core/text/error_strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final request = RequestOptions(path: '/hotels');

  DioException transport(DioExceptionType type, {Object? error}) =>
      DioException(requestOptions: request, type: type, error: error);

  DioException http(int status, [Object? body]) => DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: request, statusCode: status, data: body),
      );

  group('AppException phân loại lỗi', () {
    test('mất mạng khi ConnectivityInterceptor gắn NoInternetException', () {
      final error = AppException.from(
        transport(DioExceptionType.connectionError, error: const NoInternetException()),
      );
      expect(error.kind, AppErrorKind.network);
      expect(error.message, ErrorStrings.offline);
    });

    test('có mạng nhưng BE không chạy là lỗi hệ thống', () {
      final error = AppException.from(transport(DioExceptionType.connectionError));
      expect(error.kind, AppErrorKind.server);
      expect(error.kind.isSystem, isTrue);
      expect(error.message, ErrorStrings.serverUnreachable);
    });

    test('quá thời gian chờ là lỗi hệ thống', () {
      final error = AppException.from(transport(DioExceptionType.receiveTimeout));
      expect(error.kind, AppErrorKind.server);
    });

    test('502 từ proxy khi BE tắt là lỗi hệ thống', () {
      final error = AppException.from(http(502, '<html>Bad Gateway</html>'));
      expect(error.kind, AppErrorKind.server);
    });

    test('lỗi nghiệp vụ giữ đúng nhóm, không bị coi là lỗi hệ thống', () {
      expect(
        AppException.from(http(403, {'code': 1002, 'message': 'You do not have permission'})).kind,
        AppErrorKind.forbidden,
      );
      expect(
        AppException.from(http(404, {'code': 404, 'message': 'Hotel not found'})).kind,
        AppErrorKind.notFound,
      );
      expect(
        AppException.from(http(400, {'code': 402, 'message': 'phone: must match'})).kind,
        AppErrorKind.badRequest,
      );
      expect(AppException.from(http(401)).kind, AppErrorKind.unauthorized);
      expect(AppErrorKind.forbidden.isSystem, isFalse);
    });

    test('lỗi ngoài Dio (dữ liệu sai định dạng) là lỗi hệ thống', () {
      final error = AppException.from(const FormatException('bad json'));
      expect(error.kind, AppErrorKind.unknown);
      expect(error.kind.isSystem, isTrue);
    });
  });
}
