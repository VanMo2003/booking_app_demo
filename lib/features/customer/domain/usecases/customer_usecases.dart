import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../../data/models/customer_models.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

@injectable
class GetCustomer {
  const GetCustomer(this._repository);

  final CustomerRepository _repository;

  Future<Customer> call(int id) => _repository.getById(id);
}

/// Khách hàng tự tạo hồ sơ cho tài khoản của mình.
@injectable
class CreateCustomerProfile {
  const CreateCustomerProfile(this._repository);

  final CustomerRepository _repository;

  Future<Customer> call(CustomerRequest request) => _repository.create(request);
}

@injectable
class UpdateCustomer {
  const UpdateCustomer(this._repository);

  final CustomerRepository _repository;

  Future<Customer> call(int id, CustomerRequest request) =>
      _repository.update(id, request);
}

/// Khách từng đặt tại quầy: gắn hồ sơ vãng lai vào tài khoản mới theo SĐT.
@injectable
class LinkWalkInProfile {
  const LinkWalkInProfile(this._repository);

  final CustomerRepository _repository;

  Future<Customer> call(String phoneNumber) => _repository.linkByPhone(phoneNumber);
}

@injectable
class FindCustomersByPhone {
  const FindCustomersByPhone(this._repository);

  final CustomerRepository _repository;

  Future<List<Customer>> call(String phoneNumber) =>
      _repository.searchByPhone(phoneNumber.trim());
}

/// Nhân viên tạo hồ sơ khách vãng lai (không gắn tài khoản).
@injectable
class CreateWalkInCustomer {
  const CreateWalkInCustomer(this._repository);

  final CustomerRepository _repository;

  Future<Customer> call({
    required String fullName,
    required String phoneNumber,
    String gender = '',
    String hometown = '',
  }) =>
      _repository.create(
        CustomerRequest(
          fullName: fullName,
          phoneNumber: phoneNumber,
          gender: gender,
          hometown: hometown,
        ),
      );
}

@injectable
class GetBranchCustomers {
  const GetBranchCustomers(this._repository);

  final CustomerRepository _repository;

  Future<List<Customer>> call(int hotelId) => _repository.byHotel(hotelId);
}

/// Toàn bộ hồ sơ khách hàng (quản trị).
@injectable
class GetCustomersPage {
  const GetCustomersPage(this._repository);

  final CustomerRepository _repository;

  Future<Paged<Customer>> call({required int page, required int size}) =>
      _repository.getAll(page: page, size: size);
}
