import '../../data/models/request/create_customer_request.dart';

abstract class CustomerRepository {
  Future<void> createCustomer(CreateCustomerRequest request);
}
