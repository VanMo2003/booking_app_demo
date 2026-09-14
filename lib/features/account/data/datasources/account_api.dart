import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'account_api.g.dart';

@RestApi()
abstract class AccountApi {
  factory AccountApi(Dio dio, {String? baseUrl}) = _AccountApi;

  @POST('/accounts')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/accounts/{id}')
  Future<ApiResponse> update(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @GET('/accounts/{id}')
  Future<ApiResponse> getById(@Path('id') String id);

  @GET('/accounts')
  Future<ApiResponse> getAll(@Query('page') int page, @Query('size') int size);

  @DELETE('/accounts/{id}')
  Future<ApiResponse> delete(@Path('id') String id);
}

@module
abstract class AccountApiModule {
  @lazySingleton
  AccountApi accountApi(Dio dio) => AccountApi(dio);
}
