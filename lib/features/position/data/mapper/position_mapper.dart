import 'package:booking_app_mobile/features/position/data/models/request/position_create_dto.dart';
import 'package:booking_app_mobile/features/position/data/models/request/position_update_dto.dart';
import 'package:booking_app_mobile/features/position/data/models/response/position_response.dart';
import 'package:booking_app_mobile/features/position/domain/entity/position.dart';

class PositionMapper {
  PositionMapper._();

  static Position toEntity(PositionResponse dto) {
    return Position(
      id: dto.id ?? 0,
      name: dto.name ?? '',
      description: dto.description ?? '',
    );
  }

  static PositionCreateDto toCreate(Position position) {
    return PositionCreateDto(
      name: position.name ?? '',
      description: position.description ?? '',
    );
  }

  static PositionUpdateDto toUpdate(Position position) {
    return PositionUpdateDto(
      id: position.id ?? 0,
      name: position.name ?? '',
      description: position.description ?? '',
    );
  }

  static PositionResponse toResponse(Position position) {
    return PositionResponse(
      id: position.id ?? 0,
      name: position.name ?? '',
      description: position.description ?? '',
    );
  }
}
