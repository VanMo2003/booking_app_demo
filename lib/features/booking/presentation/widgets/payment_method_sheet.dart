import 'package:flutter/material.dart';

import '../../../../core/component/component.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/booking_strings.dart';
import 'booking_form_sections.dart';

/// Sheet đổi phương thức thanh toán của một đơn. Trả về cách mới, `null` nếu đóng.
class PaymentMethodSheet extends StatefulWidget {
  const PaymentMethodSheet({super.key, required this.current});

  final PaymentMethod current;

  static Future<PaymentMethod?> show(BuildContext context, PaymentMethod current) =>
      AppDialogs.sheet<PaymentMethod>(
        context,
        title: BookingStrings.changePaymentTitle,
        builder: (_) => PaymentMethodSheet(current: current),
      );

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  late PaymentMethod _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentMethodPicker(
          selected: _selected,
          onSelected: (method) => setState(() => _selected = method),
        ),
        const Gap(AppSpacing.sm),
        AppButton(
          label: _selected == PaymentMethod.vnPay
              ? BookingStrings.changePaymentAndPay
              : BookingStrings.changePaymentConfirm,
          expand: true,
          // Chọn lại đúng cách đang dùng thì không có gì để đổi.
          onPressed: _selected == widget.current ? null : () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
