import 'package:flutter/material.dart';

/// Bảng màu duy nhất của app. Widget không tự đặt mã màu — luôn lấy từ đây
/// (hoặc từ `Theme`, vốn cũng được dựng từ đây).
///
/// Tông chủ đạo: xanh ngọc đậm "Lagoon" gợi không khí nghỉ dưỡng, đi cùng
/// hổ phách ấm cho điểm nhấn (sao đánh giá, giá nổi bật) và nền xám ngả xanh.
abstract final class AppColors {
  // Thương hiệu
  static const primary = Color(0xFF0B6A61);
  static const primaryDark = Color(0xFF074A44);
  static const primaryDeep = Color(0xFF0B3F4A);
  static const primaryLight = Color(0xFF4A968D);
  static const primarySoft = Color(0xFFDDEFEC);
  static const accent = Color(0xFFE39B32);
  static const accentSoft = Color(0xFFFCF0DC);

  // Nền, bề mặt, chữ
  static const ground = Color(0xFFF3F6F5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSunk = Color(0xFFEAF0EE);
  static const ink = Color(0xFF132428);
  static const inkSecondary = Color(0xFF4D6166);
  static const inkTertiary = Color(0xFF7E9094);
  static const line = Color(0xFFD5DEDB);
  static const lineSoft = Color(0xFFE6ECEA);
  static const onPrimary = Color(0xFFFFFFFF);
  static const scrim = Color(0x99132428);

  // Ngữ nghĩa
  static const success = Color(0xFF1E8A5A);
  static const successSoft = Color(0xFFDDF2E7);
  static const warning = Color(0xFFB2741A);
  static const warningSoft = Color(0xFFFBEFD9);
  static const danger = Color(0xFFC03A2B);
  static const dangerSoft = Color(0xFFFAE2DF);
  static const info = Color(0xFF1F63A8);
  static const infoSoft = Color(0xFFDDE9F6);

  /// Biến thể sáng để đặt trên nền tối (toast, tooltip).
  static const successOnDark = Color(0xFF7ED6A8);
  static const dangerOnDark = Color(0xFFF3A097);
  static const infoOnDark = Color(0xFF95C0EC);

  /// Màu các chuỗi dữ liệu trong biểu đồ, theo thứ tự ưu tiên.
  static const chartSeries = <Color>[
    primary,
    accent,
    info,
    Color(0xFF8A5BC4),
    danger,
    Color(0xFF4E9F3D),
  ];

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDeep],
  );

  static const imagePlaceholderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCFE5E1), Color(0xFFB7D3CE)],
  );
}
