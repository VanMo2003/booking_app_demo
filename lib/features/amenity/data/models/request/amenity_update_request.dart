class AmenityUpdateRequest {
  final String name;
  final String description;
  final bool common;

  const AmenityUpdateRequest({
    required this.name,
    required this.description,
    required this.common,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "common": common,
      };
}
