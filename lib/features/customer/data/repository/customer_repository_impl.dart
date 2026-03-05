import 'package:injectable/injectable.dart';

import '../../../auth/data/models/response/customer_response.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasource/remote/customer_api_service.dart';
import '../models/request/create_customer_request.dart';
import '../models/request/update_customer_request.dart';

@LazySingleton(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerApiService apiService;

  CustomerRepositoryImpl(this.apiService);

  @override
  Future<void> createCustomer(CreateCustomerRequest request) async {
    await apiService.createCustomer(request);
  }

  @override
  Future<CustomerResponse> updateCustomer(
      int id, UpdateCustomerRequest request) async {
    final apiResponse = await apiService.updateCustomer(id, request);
    final payload = apiResponse.data as Map<String, dynamic>;
    return CustomerResponse.fromJson(payload);
  }
}
