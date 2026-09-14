import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/booking_strings.dart';
import '../../../../core/utils/formatters.dart';

/// Đếm ngược thời gian giữ đơn VNPay (15 phút phía BE).
class PaymentCountdown extends StatefulWidget {
  const PaymentCountdown({super.key, required this.expireAt, this.compact = false});

  final DateTime expireAt;
  final bool compact;

  @override
  State<PaymentCountdown> createState() => _PaymentCountdownState();
}

class _PaymentCountdownState extends State<PaymentCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(PaymentCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expireAt != widget.expireAt) _start();
  }

  void _start() {
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = widget.expireAt.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
    if (remaining.isNegative) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expired = _remaining == Duration.zero;
    final text = expired
        ? BookingStrings.payExpired
        : BookingStrings.payExpiresIn(Fmt.countdown(_remaining));
    final color = expired ? AppColors.danger : AppColors.warning;
    if (widget.compact) {
      return IconText(
        icon: Icons.timer_outlined,
        iconColor: color,
        text: text,
        style: AppTextStyles.captionStrong.colored(color),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: expired ? AppColors.dangerSoft : AppColors.warningSoft,
        borderRadius: AppRadius.smAll,
      ),
      child: IconText(
        icon: expired ? Icons.timer_off_outlined : Icons.timer_outlined,
        iconColor: color,
        text: text,
        maxLines: 2,
        style: AppTextStyles.bodySmall.weight(FontWeight.w600).colored(color),
      ),
    );
  }
}
