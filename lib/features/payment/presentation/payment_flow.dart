import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/booking_strings.dart';
import '../../../core/utils/external_actions.dart';
import '../../booking/domain/entities/booking.dart';
import '../domain/entities/payment_outcome.dart';
import '../domain/usecases/payment_usecases.dart';

/// Luồng thanh toán VNPay: xin link → mở cổng thanh toán trong WebView →
/// BE kiểm chữ ký kết quả → báo cho người dùng.
abstract final class PaymentFlow {
  static bool get _supportsWebView =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Trả kết quả, hoặc `null` nếu người dùng đóng giữa chừng.
  static Future<PaymentOutcome?> payBooking(BuildContext context, Booking booking) async {
    final link = await AppAction.run<String>(
      context,
      () => runAction(
        () => getIt<CreateVnPayLink>()(bookingId: booking.id, amount: booking.totalAmount),
      ),
    );
    if (!link.isSuccess || !context.mounted) return null;

    if (!_supportsWebView) {
      // Web/desktop: không chặn được URL trả về — mở tab mới, người dùng tự kiểm tra lại.
      await ExternalActions.openUrl(link.value!);
      if (context.mounted) {
        await AppDialogs.confirm(
          context,
          title: BookingStrings.paymentWebTitle,
          message: BookingStrings.paymentWebMessage,
          confirmLabel: BookingStrings.checkStatus,
          cancelLabel: AppStrings.close,
          icon: Icons.open_in_new_rounded,
        );
      }
      return null;
    }

    final outcome = await context.rootRouter.push<PaymentOutcome>(
      PaymentWebViewRoute(paymentUrl: link.value!),
    );
    if (!context.mounted) return outcome;
    if (outcome == null) {
      AppToast.info(context, BookingStrings.paymentClosed);
      return null;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => PaymentResultDialog(outcome: outcome),
    );
    return outcome;
  }
}

class PaymentResultDialog extends StatelessWidget {
  const PaymentResultDialog({super.key, required this.outcome});

  final PaymentOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (icon, color, background, title, message) = switch (outcome) {
      PaymentOutcome.success => (
          Icons.check_rounded,
          AppColors.success,
          AppColors.successSoft,
          BookingStrings.paymentSuccessTitle,
          BookingStrings.paymentSuccessMessage,
        ),
      PaymentOutcome.expired => (
          Icons.timer_off_outlined,
          AppColors.warning,
          AppColors.warningSoft,
          BookingStrings.paymentExpiredTitle,
          BookingStrings.paymentExpiredMessage,
        ),
      PaymentOutcome.failed || PaymentOutcome.invalid => (
          Icons.close_rounded,
          AppColors.danger,
          AppColors.dangerSoft,
          BookingStrings.paymentFailedTitle,
          BookingStrings.paymentFailedMessage,
        ),
    };
    return AlertDialog(
      icon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 34, color: color),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center, style: AppTextStyles.body.colored(AppColors.inkSecondary)),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        AppButton(
          label: BookingStrings.viewBooking,
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
