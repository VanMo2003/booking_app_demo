import '../../domain/entity/service.dart';
import '../models/request/service_create_dto.dart';
import '../models/request/service_update_dto.dart';

class ServiceMapper {
  ServiceMapper._();

  static ServiceCreateDto toCreate(ServiceEntity s) => ServiceCreateDto(
        name: s.name,
        unitPrice: s.unitPrice,
        description: s.description,
        hotelId: s.hotelId,
      );

  static ServiceUpdateDto toUpdate(ServiceEntity s) => ServiceUpdateDto(
        name: s.name,
        unitPrice: s.unitPrice,
        description: s.description,
      );
}
