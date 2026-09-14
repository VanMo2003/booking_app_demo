import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../color/app_colors.dart';

/// Thang chữ của app, dùng Be Vietnam Pro — font thiết kế riêng cho dấu tiếng Việt.
/// Cỡ chữ: 11.5 · 12 · 13 · 13.5 · 15 · 16 · 18 · 22 · 24 · 28.
///
/// `google_fonts` nạp file theo từng độ đậm, nên đổi độ đậm phải dùng
/// [AppTextStyleX.weight] thay vì `copyWith(fontWeight: …)`.
abstract final class AppTextStyles {
  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle _font(
    double size, {
    FontWeight weight = FontWeight.w400,
    double height = 1.4,
    double? letterSpacing,
    Color color = AppColors.ink,
    List<FontFeature>? features,
  }) =>
      GoogleFonts.beVietnamPro(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontFeatures: features,
      );

  static final display =
      _font(28, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.5);

  static final headline =
      _font(22, weight: FontWeight.w700, height: 1.25, letterSpacing: -0.3);

  static final title =
      _font(18, weight: FontWeight.w600, height: 1.3, letterSpacing: -0.1);

  static final subtitle = _font(16, weight: FontWeight.w600, height: 1.35);

  static final body = _font(15, height: 1.5);

  static final bodyMedium = _font(15, weight: FontWeight.w500, height: 1.5);

  static final bodyStrong = _font(15, weight: FontWeight.w600, height: 1.45);

  static final bodySmall =
      _font(13.5, height: 1.45, color: AppColors.inkSecondary);

  static final caption = _font(12, height: 1.35, color: AppColors.inkTertiary);

  static final captionStrong = _font(
    12,
    weight: FontWeight.w600,
    height: 1.35,
    color: AppColors.inkSecondary,
  );

  /// Nhãn nhỏ viết hoa cho tiêu đề nhóm.
  static final overline = _font(
    11.5,
    weight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.8,
    color: AppColors.inkSecondary,
  );

  static final button =
      _font(15, weight: FontWeight.w600, height: 1.2, letterSpacing: 0.1);

  static final chip = _font(13, weight: FontWeight.w500, height: 1.2);

  /// Số tiền — chữ số cùng độ rộng để thẳng hàng.
  static final money = _font(
    16,
    weight: FontWeight.w700,
    height: 1.25,
    features: _tabular,
  );

  static final moneyLarge = _font(
    22,
    weight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    features: _tabular,
  );

  static final metric = _font(
    24,
    weight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
    features: _tabular,
  );

  static final tabular = _font(15, features: _tabular);

  static TextTheme textTheme() => TextTheme(
        displaySmall: display,
        headlineMedium: headline,
        headlineSmall: _font(20, weight: FontWeight.w700, height: 1.25),
        titleLarge: title,
        titleMedium: subtitle,
        titleSmall: bodyStrong,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: bodySmall,
        labelLarge: button,
        labelMedium: chip,
        labelSmall: caption,
      );
}

extension AppTextStyleX on TextStyle {
  /// Đổi độ đậm và nạp đúng biến thể font tương ứng.
  TextStyle weight(FontWeight value) =>
      GoogleFonts.beVietnamPro(textStyle: this, fontWeight: value);

  TextStyle colored(Color value) => copyWith(color: value);
}
