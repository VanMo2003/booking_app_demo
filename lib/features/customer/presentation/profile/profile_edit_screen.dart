import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../data/models/customer_models.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customer_usecases.dart';

/// Chuẩn hoá giới tính cũ gõ tay ("nam", "nữ") về lựa chọn chuẩn.
String? normalizeGender(String value) {
  if (value.trim().isEmpty) return null;
  return AppConstants.genders.firstWhereOrNull(
        (option) => option.toLowerCase() == value.trim().toLowerCase(),
      ) ??
      value;
}

@RoutePage()
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _fullName = TextEditingController(text: widget.customer.fullName);
  late final _phone = TextEditingController(text: widget.customer.phoneNumber);
  late String? _gender = normalizeGender(widget.customer.gender);
  late String? _hometown =
      widget.customer.hometown.isEmpty ? null : widget.customer.hometown;
  bool _saving = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final sessionCubit = context.read<SessionCubit>();
    final result = await runAction(() async {
      final updated = await getIt<UpdateCustomer>()(
        widget.customer.id,
        CustomerRequest(
          fullName: _fullName.text.trim(),
          phoneNumber: _phone.text.trim(),
          gender: _gender ?? '',
          hometown: _hometown ?? '',
          pathImage: widget.customer.pathImage,
        ),
      );
      final session = sessionCubit.session;
      if (session != null) await sessionCubit.update(session.copyWith(customer: updated));
      return updated;
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) {
      AppToast.success(context, ExploreStrings.profileSaved);
      await context.router.maybePop(true);
    } else {
      AppToast.error(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: ExploreStrings.editProfile,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            AppTextField(
              controller: _fullName,
              label: ExploreStrings.fullName,
              prefixIcon: Icons.badge_outlined,
              textCapitalization: TextCapitalization.words,
              validator: Validators.required(),
            ),
            const Gap(AppSpacing.sm),
            AppTextField(
              controller: _phone,
              label: ExploreStrings.phone,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10,
              validator: Validators.phone,
            ),
            const Gap(AppSpacing.sm),
            AppDropdownField<String>(
              label: ExploreStrings.gender,
              prefixIcon: Icons.wc_rounded,
              items: AppConstants.genders,
              value: _gender,
              itemLabel: (item) => item,
              onChanged: (value) => setState(() => _gender = value),
            ),
            const Gap(AppSpacing.sm),
            AppDropdownField<String>(
              label: ExploreStrings.hometown,
              prefixIcon: Icons.place_outlined,
              items: AppConstants.provinces,
              value: _hometown,
              itemLabel: (item) => item,
              onChanged: (value) => setState(() => _hometown = value),
            ),
            const Gap(AppSpacing.lg),
            Text(ExploreStrings.passwordChangeUnavailable, style: AppTextStyles.caption),
          ],
        ),
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: AppStrings.saveChanges,
          expand: true,
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}
