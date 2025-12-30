import 'package:injectable/injectable.dart';

import '../repositories/customer_repository.dart';
import '../../data/models/request/create_customer_request.dart';

@injectable
class CreateCustomerUseCase {
  final CustomerRepository repository;
  CreateCustomerUseCase(this.repository);

  Future<void> call(CreateCustomerRequest request) async {
    return repository.createCustomer(request);
  }
}
