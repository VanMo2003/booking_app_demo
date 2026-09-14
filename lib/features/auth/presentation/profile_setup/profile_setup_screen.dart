import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/color/app_colors.dart';
import '../../../../core/component/component.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/app_strings.dart';
import '../../../../core/text/auth_strings.dart';
import '../../../../core/text/explore_strings.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_layout.dart';
import 'profile_setup_cubit.dart';

/// Tài khoản khách chưa có hồ sơ: thử nhận lại hồ sơ đặt tại quầy theo SĐT,
/// không có thì tạo hồ sơ mới.
@RoutePage()
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key, this.returnResult = false});

  final bool returnResult;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileSetupCubit>(),
      child: _ProfileSetupView(returnResult: returnResult),
    );
  }
}

class _ProfileSetupView extends StatefulWidget {
  const _ProfileSetupView({required this.returnResult});

  final bool returnResult;

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final _linkForm = GlobalKey<FormState>();
  final _createForm = GlobalKey<FormState>();
  final _linkPhone = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  String? _gender;
  String? _hometown;

  @override
  void dispose() {
    _linkPhone.dispose();
    _fullName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    AppToast.success(context, AuthStrings.setupDone);
    if (widget.returnResult) {
      await context.router.maybePop(true);
    } else {
      await context.router.replaceAll([const CustomerShellRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
      listener: (context, state) {
        if (state.error != null) AppToast.error(context, state.error!);
        if (state.done) _finish();
        if (state.notFoundPhone != null && _phone.text.isEmpty) {
          _phone.text = state.notFoundPhone!;
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProfileSetupCubit>();
        return AuthLayout(
          title: AuthStrings.setupTitle,
          subtitle: AuthStrings.setupCreateSubtitle,
          showBack: context.router.canPop(),
          child: AnimatedSize(
            duration: AppDurations.normal,
            alignment: Alignment.topCenter,
            child: state.step == ProfileSetupStep.link
                ? _buildLink(state, cubit)
                : _buildCreate(state, cubit),
          ),
        );
      },
    );
  }

  Widget _buildLink(ProfileSetupState state, ProfileSetupCubit cubit) {
    return Form(
      key: _linkForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AuthStrings.setupLinkHeadline, style: AppTextStyles.title),
          const Gap(AppSpacing.xs),
          Text(AuthStrings.setupLinkSubtitle, style: AppTextStyles.bodySmall),
          const Gap(AppSpacing.md),
          AppTextField(
            controller: _linkPhone,
            label: ExploreStrings.phone,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            validator: Validators.phone,
          ),
          const Gap(AppSpacing.md),
          AppButton(
            label: AuthStrings.setupLinkAction,
            icon: Icons.person_search_rounded,
            expand: true,
            loading: state.busy,
            onPressed: () {
              if (_linkForm.currentState!.validate()) {
                cubit.linkByPhone(_linkPhone.text);
              }
            },
          ),
          const Gap(AppSpacing.xs),
          AppButton.text(
            label: AuthStrings.setupNewProfile,
            onPressed: state.busy ? null : cubit.showCreateForm,
          ),
        ],
      ),
    );
  }

  Widget _buildCreate(ProfileSetupState state, ProfileSetupCubit cubit) {
    return Form(
      key: _createForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AuthStrings.setupCreateHeadline, style: AppTextStyles.title),
          if (state.notFoundPhone != null) ...[
            const Gap(AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: AppRadius.smAll,
              ),
              child: IconText(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.info,
                maxLines: 3,
                text: AuthStrings.setupNotFound,
                style: AppTextStyles.bodySmall.colored(AppColors.info),
              ),
            ),
          ],
          const Gap(AppSpacing.md),
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
          AppButton(
            label: AuthStrings.setupCreateAction,
            expand: true,
            loading: state.busy,
            onPressed: () {
              if (!_createForm.currentState!.validate()) return;
              cubit.create(
                fullName: _fullName.text,
                phone: _phone.text,
                gender: _gender ?? '',
                hometown: _hometown ?? '',
              );
            },
          ),
          if (!widget.returnResult) ...[
            const Gap(AppSpacing.xs),
            AppButton.text(
              label: AppStrings.back,
              onPressed: state.busy
                  ? null
                  : () => context.router.replaceAll([const CustomerShellRoute()]),
            ),
          ],
        ],
      ),
    );
  }
}
