import 'package:injectable/injectable.dart';

import '../../domain/repositories/customer_repository.dart';
import '../datasource/remote/customer_api_service.dart';
import '../models/request/create_customer_request.dart';

@LazySingleton(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerApiService apiService;

  CustomerRepositoryImpl(this.apiService);

  @override
  Future<void> createCustomer(CreateCustomerRequest request) async {
    await apiService.createCustomer(request);
  }
}
