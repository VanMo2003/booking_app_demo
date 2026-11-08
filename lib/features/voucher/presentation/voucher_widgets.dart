import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/style/style.dart';
import '../../../core/text/discover_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/voucher.dart';

/// "Giảm 10%, tối đa 200 N" hoặc "Giảm 200.000 ₫".
String voucherOff(Voucher voucher) => voucher.discountType == DiscountType.percent
    ? VoucherStrings.offPercent(
        Fmt.decimal(voucher.value),
        voucher.maxDiscount == null ? null : Fmt.moneyCompact(voucher.maxDiscount),
      )
    : VoucherStrings.off(Fmt.money(voucher.value));

/// Điều kiện ngắn: đơn tối thiểu, hạn dùng, cơ sở.
String voucherConditions(Voucher voucher) => [
      if (voucher.minOrderAmount != null) VoucherStrings.minOrderLine(Fmt.moneyCompact(voucher.minOrderAmount)),
      VoucherStrings.validUntil(Fmt.date(voucher.endsAt)),
      voucher.hotelName ?? voucher.hotelChainName ?? '',
    ].where((text) => text.isNotEmpty).join(' · ');

bool voucherExpired(Voucher voucher) => voucher.endsAt.isBefore(DateOnly.today());

/// Vé giảm giá: mã to bên trái, mô tả và điều kiện bên phải; chạm để sao chép mã (hoặc [onTap]).
class VoucherTicket extends StatelessWidget {
  const VoucherTicket({super.key, required this.voucher, this.width, this.onTap, this.selected = false});

  final Voucher voucher;
  final double? width;
  final VoidCallback? onTap;
  final bool selected;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: voucher.code));
    if (context.mounted) AppToast.success(context, VoucherStrings.copied);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: selected ? AppColors.primary : AppColors.lineSoft, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () => _copy(context),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 86,
                  color: AppColors.accent,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_offer_rounded, color: AppColors.onPrimary, size: 20),
                      const Gap(4),
                      FittedBox(
                        child: Text(voucher.code, style: AppTextStyles.captionStrong.colored(AppColors.onPrimary)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(voucher.title, style: AppTextStyles.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const Gap(2),
                        Text(voucherOff(voucher), style: AppTextStyles.captionStrong.colored(AppColors.danger)),
                        Text(
                          voucherConditions(voucher),
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
