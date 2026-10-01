import 'package:flutter/material.dart';

import '../enums/app_enums.dart';
import 'app_colors.dart';

/// Sắc thái trạng thái — tách khỏi màu thương hiệu để một trạng thái luôn
/// mang cùng một màu ở mọi màn.
enum StatusTone { neutral, brand, info, success, warning, danger }

class ToneColors {
  const ToneColors(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

extension StatusToneColors on StatusTone {
  ToneColors get colors => switch (this) {
        StatusTone.neutral =>
          const ToneColors(AppColors.inkSecondary, AppColors.surfaceSunk),
        StatusTone.brand =>
          const ToneColors(AppColors.primary, AppColors.primarySoft),
        StatusTone.info => const ToneColors(AppColors.info, AppColors.infoSoft),
        StatusTone.success =>
          const ToneColors(AppColors.success, AppColors.successSoft),
        StatusTone.warning =>
          const ToneColors(AppColors.warning, AppColors.warningSoft),
        StatusTone.danger =>
          const ToneColors(AppColors.danger, AppColors.dangerSoft),
      };
}

extension BookingStatusTone on BookingStatus {
  StatusTone get tone => switch (this) {
        BookingStatus.pending || BookingStatus.paying => StatusTone.warning,
        BookingStatus.confirmed => StatusTone.info,
        BookingStatus.completed => StatusTone.success,
        BookingStatus.canceled => StatusTone.danger,
      };
}

extension TourBookingStatusTone on TourBookingStatus {
  StatusTone get tone => switch (this) {
        TourBookingStatus.pending => StatusTone.warning,
        TourBookingStatus.confirmed => StatusTone.info,
        TourBookingStatus.completed => StatusTone.success,
        TourBookingStatus.canceled => StatusTone.danger,
      };
}

extension PaymentStatusTone on PaymentStatus {
  StatusTone get tone => switch (this) {
        PaymentStatus.unpaid => StatusTone.neutral,
        PaymentStatus.pending => StatusTone.warning,
        PaymentStatus.paid => StatusTone.success,
        PaymentStatus.failed => StatusTone.danger,
      };
}

extension RoomStatusTone on RoomStatus {
  StatusTone get tone => switch (this) {
        RoomStatus.available => StatusTone.success,
        RoomStatus.booked => StatusTone.warning,
        RoomStatus.occupied => StatusTone.info,
        RoomStatus.maintenance => StatusTone.neutral,
      };
}

extension HotelStatusTone on HotelStatus {
  StatusTone get tone => switch (this) {
        HotelStatus.available => StatusTone.success,
        HotelStatus.full => StatusTone.danger,
        HotelStatus.inactive => StatusTone.neutral,
      };
}

extension PayrollStatusTone on PayrollStatus {
  StatusTone get tone => switch (this) {
        PayrollStatus.approved => StatusTone.info,
        PayrollStatus.paid => StatusTone.success,
        PayrollStatus.rejected => StatusTone.danger,
      };
}

extension ApprovalStatusTone on ApprovalStatus {
  StatusTone get tone => switch (this) {
        ApprovalStatus.pending => StatusTone.warning,
        ApprovalStatus.approved => StatusTone.success,
        ApprovalStatus.rejected => StatusTone.danger,
      };
}

extension RoleTone on Role {
  StatusTone get tone => switch (this) {
        Role.admin => StatusTone.danger,
        Role.hotelOwner => StatusTone.warning,
        Role.hotelManager => StatusTone.info,
        Role.staff => StatusTone.brand,
        Role.customer => StatusTone.neutral,
      };
}
