import '../entity/service.dart';

abstract class ServiceRepository {
  Future<List<ServiceEntity>> getServices({required int hotelId});
  Future<ServiceEntity> createService(ServiceEntity service);
  Future<ServiceEntity> updateService(ServiceEntity service);
  Future<void> deleteService(int id);
}
