import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:booking_app_mobile/core/api/dio_client.dart';
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
  final DioClient dioClient;

  ServiceRepositoryImpl(this.apiService, this.dioClient);

  @override
  Future<ServiceEntity> createService(ServiceEntity service) async {
    try {
      final body = ServiceCreateDto(
        name: service.name,
        unitPrice: service.unitPrice,
        description: service.description,
        hotelId: service.hotelId,
      );
      final ApiResponse response = await apiService.createService(body);
      return ServiceResponse.fromJson(response.data).toEntity();
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<void> deleteService(int id) async {
    try {
      await apiService.deleteService(id);
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<List<ServiceEntity>> getServices({required int hotelId}) async {
    try {
      final ApiResponse response = await apiService.getServices(hotelId);
      final data = response.data as List<dynamic>;
      return data.map((e) => ServiceResponse.fromJson(e).toEntity()).toList();
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<ServiceEntity> updateService(ServiceEntity service) async {
    try {
      final id = service.id ?? 0;
      final body = ServiceUpdateDto(
        name: service.name,
        unitPrice: service.unitPrice,
        description: service.description,
      );
      final ApiResponse response = await apiService.updateService(id, body);
      return ServiceResponse.fromJson(response.data).toEntity();
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }
}
