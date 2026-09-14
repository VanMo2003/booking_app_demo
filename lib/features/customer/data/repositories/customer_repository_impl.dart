import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_api.dart';
import '../models/customer_models.dart';

@LazySingleton(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._api);

  final CustomerApi _api;

  @override
  Future<Customer> create(CustomerRequest request) async =>
      (await _api.create(request.toJson())).parse(CustomerModel.fromJson);

  @override
  Future<Customer> update(int id, CustomerRequest request) async =>
      (await _api.update(id, request.toJson())).parse(CustomerModel.fromJson);

  @override
  Future<Customer> getById(int id) async =>
      (await _api.getById(id)).parse(CustomerModel.fromJson);

  @override
  Future<Paged<Customer>> getAll({required int page, required int size}) async =>
      (await _api.getAll(page, size)).parsePage(CustomerModel.fromJson);

  @override
  Future<List<Customer>> byHotel(int hotelId) async =>
      (await _api.byHotel(hotelId)).parseList(CustomerModel.fromJson);

  @override
  Future<List<Customer>> searchByPhone(String phoneNumber) async =>
      (await _api.searchByPhone(phoneNumber)).parseList(CustomerModel.fromJson);

  @override
  Future<Customer> linkByPhone(String phoneNumber) async =>
      (await _api.linkByPhone({'phoneNumber': phoneNumber}))
          .parse(CustomerModel.fromJson);
}
