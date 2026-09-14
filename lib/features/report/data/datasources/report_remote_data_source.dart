import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_response.dart';
import '../../domain/entities/report_entities.dart';

/// Báo cáo cơ sở và báo cáo chuỗi có cùng hợp đồng, chỉ khác tiền tố `/chain`
/// và tên tham số id, nên nguồn dữ liệu này dựng path theo [ReportScope]
/// thay vì khai báo hai lần mỗi endpoint.
@lazySingleton
class ReportRemoteDataSource {
  ReportRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ApiResponse> get(
    ReportScope scope,
    String endpoint, [
    Map<String, dynamic> query = const {},
  ]) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reports${scope.pathPrefix}/$endpoint',
      queryParameters: {...scope.idQuery, ...query},
    );
    return ApiResponse.fromJson(response.data ?? const {});
  }

  /// File `.xlsx` dạng bytes.
  Future<List<int>> export(ReportScope scope, Map<String, dynamic> query) async {
    final response = await _dio.get<List<int>>(
      '/reports${scope.pathPrefix}/export',
      queryParameters: {...scope.idQuery, ...query},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }
}
