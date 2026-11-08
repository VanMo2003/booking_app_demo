import 'package:flutter/material.dart';

/// Chủ đề của tour, cũng là sở thích khách chọn ở màn đầu tiên; BE gợi ý tour theo chúng.
enum TravelTheme {
  beach('BEACH', 'Biển', Icons.beach_access_rounded),
  mountain('MOUNTAIN', 'Núi', Icons.terrain_rounded),
  culture('CULTURE', 'Văn hoá', Icons.account_balance_rounded),
  food('FOOD', 'Ẩm thực', Icons.ramen_dining_rounded),
  nature('NATURE', 'Thiên nhiên', Icons.forest_rounded),
  adventure('ADVENTURE', 'Khám phá', Icons.hiking_rounded),
  city('CITY', 'Thành phố', Icons.location_city_rounded),
  relax('RELAX', 'Nghỉ dưỡng', Icons.spa_rounded);

  const TravelTheme(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static TravelTheme? tryParse(String? raw) {
    for (final theme in values) {
      if (theme.value == raw) return theme;
    }
    return null;
  }
}
