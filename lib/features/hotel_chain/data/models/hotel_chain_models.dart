import '../../../../core/network/json_reader.dart';
import '../../../hotel/data/models/hotel_models.dart';
import '../../domain/entities/hotel_chain.dart';

/// JSON `ListHotelChainResponse` / `HotelChainDetailResponse` ↔ entity.
abstract final class HotelChainModel {
  static HotelChain fromJson(Json json) => HotelChain(
        id: json.integer('id'),
        name: json.str('name'),
        description: json.str('description'),
        pathImage: json.strOrNull('pathImage'),
        accountId: json.strOrNull('accountId'),
      );

  static Json toJson(HotelChain chain) => {
        'id': chain.id,
        'name': chain.name,
        'description': chain.description,
        'pathImage': chain.pathImage,
        'accountId': chain.accountId,
      };

  static HotelChainDetail detailFromJson(Json json) => HotelChainDetail(
        chain: fromJson(json),
        hotels: json.listOf('hotels', HotelModel.fromJson),
      );
}

class HotelChainRequest {
  const HotelChainRequest({
    required this.name,
    this.description = '',
    this.pathImage,
    this.accountId,
  });

  final String name;
  final String description;
  final String? pathImage;

  /// Chỉ gửi khi tạo mới.
  final String? accountId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'pathImage': pathImage ?? '',
        if (accountId != null) 'accountId': accountId,
      };
}
