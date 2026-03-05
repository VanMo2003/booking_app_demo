import '../../data/models/request/create_customer_request.dart';
import '../../../auth/data/models/response/customer_response.dart';
import '../../data/models/request/update_customer_request.dart';

abstract class CustomerRepository {
  Future<void> createCustomer(CreateCustomerRequest request);

  Future<CustomerResponse> updateCustomer(
      int id, UpdateCustomerRequest request);
}
