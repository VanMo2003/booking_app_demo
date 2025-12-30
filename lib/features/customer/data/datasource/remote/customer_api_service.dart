import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';
import '../../models/request/create_customer_request.dart';

part 'customer_api_service.g.dart';

@RestApi()
abstract class CustomerApiService {
  factory CustomerApiService(Dio dio, {String? baseUrl}) = _CustomerApiService;

  @POST('/customers')
  Future<ApiResponse> createCustomer(@Body() CreateCustomerRequest body);
}
