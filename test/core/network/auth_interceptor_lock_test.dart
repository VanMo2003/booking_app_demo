import 'package:booking_app_mobile/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> _response(int status, Object? body) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/notifications'),
      statusCode: status,
      data: body,
    );

void main() {
  test('a locked account (403, code 1026) is recognised', () {
    expect(
      AuthInterceptor.isAccountLocked(
          _response(403, {'success': false, 'code': 1026})),
      isTrue,
    );
  });

  test('other refusals are not a lock', () {
    expect(AuthInterceptor.isAccountLocked(_response(403, {'code': 1001})),
        isFalse);
    expect(AuthInterceptor.isAccountLocked(_response(401, {'code': 1026})),
        isFalse);
    expect(
        AuthInterceptor.isAccountLocked(_response(403, 'Forbidden')), isFalse);
    expect(AuthInterceptor.isAccountLocked(null), isFalse);
  });
}
