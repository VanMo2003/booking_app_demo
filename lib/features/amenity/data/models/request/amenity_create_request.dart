class AmenityCreateRequest {
  final String name;
  final String description;
  final bool common;
  final int hotelId;
  final int? roomId;

  const AmenityCreateRequest({
    required this.name,
    required this.description,
    required this.common,
    required this.hotelId,
    this.roomId,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "common": common,
        "hotelId": hotelId,
        if (roomId != null) "roomId": roomId,
      };
}
