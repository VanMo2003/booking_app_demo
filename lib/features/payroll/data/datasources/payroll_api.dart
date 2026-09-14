import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'payroll_api.g.dart';

@RestApi()
abstract class PayrollApi {
  factory PayrollApi(Dio dio, {String? baseUrl}) = _PayrollApi;

  @POST('/payrolls')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/payrolls/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );
}

@module
abstract class PayrollApiModule {
  @lazySingleton
  PayrollApi payrollApi(Dio dio) => PayrollApi(dio);
}
