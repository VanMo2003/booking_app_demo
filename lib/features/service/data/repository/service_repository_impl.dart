import 'package:injectable/injectable.dart';
import '../../../share/data/models/api_response.dart';
import '../../domain/entity/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasource/remote/service_api_service.dart';
import '../models/response/service_response.dart';
import '../models/request/service_create_dto.dart';
import '../models/request/service_update_dto.dart';

@LazySingleton(as: ServiceRepository)
class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceApiService apiService;
  ServiceRepositoryImpl(this.apiService);

  @override
  Future<ServiceEntity> createService(ServiceEntity service) async {
    final body = ServiceCreateDto(
      name: service.name,
      unitPrice: service.unitPrice,
      description: service.description,
      hotelId: service.hotelId,
    );
    final ApiResponse response = await apiService.createService(body);
    return ServiceResponse.fromJson(response.data).toEntity();
  }

  @override
  Future<void> deleteService(int id) async {
    await apiService.deleteService(id);
  }

  @override
  Future<List<ServiceEntity>> getServices({required int hotelId}) async {
    final ApiResponse response = await apiService.getServices(hotelId);
    final data = response.data as List<dynamic>;
    return data.map((e) => ServiceResponse.fromJson(e).toEntity()).toList();
  }

  @override
  Future<ServiceEntity> updateService(ServiceEntity service) async {
    final id = service.id ?? 0;
    final body = ServiceUpdateDto(
      name: service.name,
      unitPrice: service.unitPrice,
      description: service.description,
    );
    final ApiResponse response = await apiService.updateService(id, body);
    return ServiceResponse.fromJson(response.data).toEntity();
  }
}
