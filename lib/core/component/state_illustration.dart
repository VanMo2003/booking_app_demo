import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../color/status_colors.dart';

/// Ảnh minh hoạ dựng sẵn cho các màn trạng thái.
enum AppIllustrationType {
  /// Máy chủ không phản hồi / lỗi hệ thống.
  serverError,

  /// Mất kết nối mạng.
  offline,

  /// Không có quyền, không tìm thấy, dữ liệu không hợp lệ.
  requestError,

  /// Danh sách trống.
  empty,

  /// Cần đăng nhập.
  login,

  /// Hồ sơ đang chờ quản trị viên duyệt.
  pending,

  /// Hồ sơ đã được duyệt.
  approved,

  /// Hồ sơ bị từ chối.
  rejected,

  /// Hộp thông báo trống.
  notifications,
}

/// Ảnh minh hoạ vẽ bằng widget, không cần file ảnh: nền tròn theo tông trạng thái,
/// thẻ biểu tượng xếp lớp và huy hiệu nhỏ. Sắc nét ở mọi kích thước, tự lấy
/// kích thước từ khung chứa.
class AppIllustration extends StatelessWidget {
  const AppIllustration({super.key, required this.type, this.icon});

  final AppIllustrationType type;

  /// Thay biểu tượng chính trên thẻ (ví dụ giường cho danh sách phòng trống).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final spec = _IllustrationSpec.of(type);
    final colors = spec.tone.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 164.0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 164.0,
        );
        final card = size * 0.5;
        final badge = size * 0.22;
        final cardRadius = BorderRadius.circular(card * 0.26);
        return SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.9,
                height: size * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.background,
                      colors.background.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                size: Size.square(size),
                painter: _SparklePainter(
                  color: colors.foreground.withValues(alpha: 0.35),
                ),
              ),
              Transform.rotate(
                angle: 0.2,
                child: Container(
                  width: card,
                  height: card,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.65),
                    borderRadius: cardRadius,
                    border: Border.all(color: AppColors.lineSoft),
                  ),
                ),
              ),
              Transform.rotate(
                angle: -0.06,
                child: Container(
                  width: card,
                  height: card,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: cardRadius,
                    border: Border.all(color: AppColors.lineSoft),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.08),
                        blurRadius: size * 0.08,
                        offset: Offset(0, size * 0.03),
                      ),
                    ],
                  ),
                  child: Icon(icon ?? spec.icon, size: card * 0.5, color: colors.foreground),
                ),
              ),
              Positioned(
                right: size * 0.19,
                bottom: size * 0.19,
                child: Container(
                  width: badge,
                  height: badge,
                  decoration: BoxDecoration(
                    color: colors.foreground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: size * 0.02),
                  ),
                  child: Icon(spec.badge, size: badge * 0.55, color: AppColors.onPrimary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IllustrationSpec {
  const _IllustrationSpec(this.icon, this.badge, this.tone);

  final IconData icon;
  final IconData badge;
  final StatusTone tone;

  static _IllustrationSpec of(AppIllustrationType type) => switch (type) {
        AppIllustrationType.serverError => const _IllustrationSpec(
            Icons.dns_rounded,
            Icons.priority_high_rounded,
            StatusTone.danger,
          ),
        AppIllustrationType.offline => const _IllustrationSpec(
            Icons.wifi_off_rounded,
            Icons.sync_problem_rounded,
            StatusTone.warning,
          ),
        AppIllustrationType.requestError => const _IllustrationSpec(
            Icons.find_in_page_outlined,
            Icons.question_mark_rounded,
            StatusTone.info,
          ),
        AppIllustrationType.empty => const _IllustrationSpec(
            Icons.inbox_rounded,
            Icons.add_rounded,
            StatusTone.brand,
          ),
        AppIllustrationType.login => const _IllustrationSpec(
            Icons.lock_outline_rounded,
            Icons.person_rounded,
            StatusTone.brand,
          ),
        AppIllustrationType.pending => const _IllustrationSpec(
            Icons.storefront_rounded,
            Icons.hourglass_top_rounded,
            StatusTone.warning,
          ),
        AppIllustrationType.approved => const _IllustrationSpec(
            Icons.storefront_rounded,
            Icons.check_rounded,
            StatusTone.success,
          ),
        AppIllustrationType.rejected => const _IllustrationSpec(
            Icons.assignment_late_outlined,
            Icons.close_rounded,
            StatusTone.danger,
          ),
        AppIllustrationType.notifications => const _IllustrationSpec(
            Icons.notifications_none_rounded,
            Icons.done_rounded,
            StatusTone.brand,
          ),
      };
}

/// Chấm tròn và dấu lấp lánh trang trí quanh ảnh.
class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(s * 0.15, s * 0.32), s * 0.022, dot);
    canvas.drawCircle(Offset(s * 0.87, s * 0.22), s * 0.016, dot);
    canvas.drawCircle(Offset(s * 0.12, s * 0.74), s * 0.013, dot);

    final stroke = Paint()
      ..color = color
      ..strokeWidth = s * 0.014
      ..strokeCap = StrokeCap.round;
    for (final (center, arm) in [
      (Offset(s * 0.84, s * 0.6), s * 0.04),
      (Offset(s * 0.27, s * 0.12), s * 0.03),
    ]) {
      canvas.drawLine(center - Offset(arm, 0), center + Offset(arm, 0), stroke);
      canvas.drawLine(center - Offset(0, arm), center + Offset(0, arm), stroke);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}
