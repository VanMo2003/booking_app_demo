import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/auth_strings.dart';
import '../../../core/text/error_strings.dart';
import '../../../core/text/partner_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/login/login_cubit.dart';
import '../../auth/presentation/widgets/auth_layout.dart';
import 'owner_register_cubit.dart';
import 'widgets/hotel_profile_fields.dart';

/// Khách vãng lai đăng ký làm chủ khách sạn: tài khoản → thông tin khách sạn.
/// Gửi xong được đăng nhập luôn và chuyển tới màn chờ duyệt.
@RoutePage()
class OwnerRegisterScreen extends StatelessWidget {
  const OwnerRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OwnerRegisterCubit>(),
      child: const _OwnerRegisterView(),
    );
  }
}

class _OwnerRegisterView extends StatefulWidget {
  const _OwnerRegisterView();

  @override
  State<_OwnerRegisterView> createState() => _OwnerRegisterViewState();
}

class _OwnerRegisterViewState extends State<_OwnerRegisterView> {
  final _accountForm = GlobalKey<FormState>();
  final _hotelForm = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _fields = HotelProfileControllers();
  int _step = 0;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    _fields.dispose();
    super.dispose();
  }

  void _next() {
    if (!_accountForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _step = 1);
  }

  void _submit() {
    if (!_hotelForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<OwnerRegisterCubit>().submit(
          username: _username.text,
          password: _password.text,
          profile: _fields.toProfile(),
        );
  }

  void _onState(AuthFormState state) {
    switch (state.status) {
      case ViewStatus.success:
        AppToast.success(context, PartnerStrings.submitted);
        context.router.replaceAll([const OwnerStatusRoute()]);
      case ViewStatus.failure:
        final error = state.error ?? ErrorStrings.unknown;
        if (error == PartnerStrings.registeredLoginFailed) {
          AppToast.info(context, error);
          context.router.replaceAll([LoginRoute()]);
          return;
        }
        if (error == ErrorStrings.usernameTaken) setState(() => _step = 0);
        AppToast.error(context, error);
      case ViewStatus.initial || ViewStatus.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerRegisterCubit, AuthFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) => _onState(state),
      builder: (context, state) {
        return PopScope(
          canPop: _step == 0 && !state.isLoading,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _step == 1 && !state.isLoading) setState(() => _step = 0);
          },
          child: AuthLayout(
            title: PartnerStrings.registerHeadline,
            subtitle: PartnerStrings.registerSubtitle,
            showBack: true,
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(PartnerStrings.haveAccount, style: AppTextStyles.bodySmall),
                ),
                AppButton.text(
                  label: AuthStrings.loginAction,
                  size: AppButtonSize.small,
                  onPressed: state.isLoading ? null : () => context.router.push(LoginRoute()),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StepProgress(
                  steps: const [PartnerStrings.stepAccount, PartnerStrings.stepHotel],
                  current: _step,
                ),
                const Gap(AppSpacing.lg),
                AnimatedSize(
                  duration: AppDurations.normal,
                  alignment: Alignment.topCenter,
                  child: _step == 0 ? _accountStep() : _hotelStep(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _accountStep() {
    return Form(
      key: _accountForm,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(PartnerStrings.accountTitle, style: AppTextStyles.title),
            const Gap(AppSpacing.xxs),
            Text(PartnerStrings.accountHint, style: AppTextStyles.bodySmall),
            const Gap(AppSpacing.md),
            AppTextField(
              controller: _username,
              label: AuthStrings.username,
              helper: AuthStrings.usernameHint,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername],
              validator: Validators.username,
            ),
            const Gap(AppSpacing.sm),
            AppPasswordField(
              controller: _password,
              label: AuthStrings.password,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
            ),
            const Gap(AppSpacing.sm),
            AppPasswordField(
              controller: _confirm,
              label: AuthStrings.confirmPassword,
              textInputAction: TextInputAction.done,
              validator: Validators.confirmPassword(_password),
              onSubmitted: (_) => _next(),
            ),
            const Gap(AppSpacing.lg),
            AppButton(label: AppStrings.next, expand: true, onPressed: _next),
          ],
        ),
      ),
    );
  }

  Widget _hotelStep(AuthFormState state) {
    return Form(
      key: _hotelForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(PartnerStrings.hotelTitle, style: AppTextStyles.title),
          const Gap(AppSpacing.xxs),
          Text(PartnerStrings.hotelHint, style: AppTextStyles.bodySmall),
          const Gap(AppSpacing.md),
          HotelProfileFields(fields: _fields),
          const Gap(AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: AppStrings.back,
                  onPressed: state.isLoading ? null : () => setState(() => _step = 0),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: PartnerStrings.submit,
                  loading: state.isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
