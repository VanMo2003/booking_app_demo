import 'package:flutter/material.dart';

import '../color/app_colors.dart';

/// Khoảng cách theo lưới 4pt.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Lề ngang chuẩn của mọi trang.
  static const EdgeInsets page = EdgeInsets.fromLTRB(md, md, md, xl);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets card = EdgeInsets.all(md);

  /// Chừa chỗ cho nút nổi / thanh hành động dưới đáy.
  static const double bottomBarClearance = 96;
}

abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius sheetTop =
      BorderRadius.vertical(top: Radius.circular(xl));
}

abstract final class AppShadows {
  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> raised = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.10),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static final List<BoxShadow> bottomBar = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
}
