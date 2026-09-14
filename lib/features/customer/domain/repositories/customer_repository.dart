import '../../../../core/network/paged.dart';
import '../../data/models/customer_models.dart';
import '../entities/customer.dart';

abstract interface class CustomerRepository {
  Future<Customer> create(CustomerRequest request);

  Future<Customer> update(int id, CustomerRequest request);

  Future<Customer> getById(int id);

  Future<Paged<Customer>> getAll({required int page, required int size});

  /// Khách đã từng có đơn ở cơ sở.
  Future<List<Customer>> byHotel(int hotelId);

  Future<List<Customer>> searchByPhone(String phoneNumber);

  Future<Customer> linkByPhone(String phoneNumber);
}
