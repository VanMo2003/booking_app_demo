import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/component/component.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/partner_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../hotel_chain/data/models/hotel_chain_models.dart';
import '../../../hotel_chain/domain/entities/hotel_chain.dart';

/// Bộ điều khiển các ô thông tin khách sạn. Màn chứa tạo và huỷ cùng vòng đời.
class HotelProfileControllers {
  final hotelName = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final ownerName = TextEditingController();
  final email = TextEditingController();
  final description = TextEditingController();

  void fill(HotelChain? chain) {
    if (chain == null) return;
    hotelName.text = chain.name;
    address.text = chain.address;
    phone.text = chain.phone;
    ownerName.text = chain.ownerName;
    email.text = chain.email;
    description.text = chain.description;
  }

  HotelChainProfile toProfile() => HotelChainProfile(
        hotelName: hotelName.text,
        address: address.text,
        phone: phone.text,
        email: email.text,
        ownerName: ownerName.text,
        description: description.text,
      );

  void dispose() {
    for (final controller in [hotelName, address, phone, ownerName, email, description]) {
      controller.dispose();
    }
  }
}

/// Ô nhập thông tin khách sạn và người đại diện — dùng chung cho đăng ký chủ
/// khách sạn, sửa/gửi lại hồ sơ và tạo chuỗi mới. Đặt bên trong một `Form`.
class HotelProfileFields extends StatelessWidget {
  const HotelProfileFields({super.key, required this.fields});

  final HotelProfileControllers fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: fields.hotelName,
          label: PartnerStrings.hotelName,
          prefixIcon: Icons.apartment_rounded,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: Validators.required(),
        ),
        const Gap(AppSpacing.sm),
        AppTextField(
          controller: fields.address,
          label: PartnerStrings.hotelAddress,
          prefixIcon: Icons.location_on_outlined,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.fullStreetAddress],
          validator: Validators.required(),
        ),
        const Gap(AppSpacing.sm),
        AppTextField(
          controller: fields.phone,
          label: PartnerStrings.hotelPhone,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 10,
          textInputAction: TextInputAction.next,
          validator: Validators.phone,
        ),
        const Gap(AppSpacing.sm),
        AppTextField(
          controller: fields.ownerName,
          label: PartnerStrings.ownerName,
          prefixIcon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          validator: Validators.required(),
        ),
        const Gap(AppSpacing.sm),
        AppTextField(
          controller: fields.email,
          label: PartnerStrings.email,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          validator: Validators.email,
        ),
        const Gap(AppSpacing.sm),
        AppTextField(
          controller: fields.description,
          label: PartnerStrings.description,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
