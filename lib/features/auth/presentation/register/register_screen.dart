import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/auth_strings.dart';
import '../../../../core/utils/validators.dart';
import '../login/login_cubit.dart';
import '../widgets/auth_layout.dart';

/// Tạo tài khoản khách hàng, đăng nhập luôn rồi sang Hoàn tất hồ sơ.
@RoutePage()
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, this.returnResult = false});

  final bool returnResult;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: _RegisterView(returnResult: returnResult),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({required this.returnResult});

  final bool returnResult;

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<RegisterCubit>().submit(
          username: _username.text,
          password: _password.text,
        );
  }

  Future<void> _onSuccess() async {
    AppToast.success(context, AuthStrings.registerSuccess);
    if (widget.returnResult) {
      final done = await context.router.push<bool>(ProfileSetupRoute(returnResult: true));
      if (mounted) await context.router.maybePop(done == true);
      return;
    }
    await context.router.replaceAll([const CustomerShellRoute(), ProfileSetupRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, AuthFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ViewStatus.failure) {
          AppToast.error(context, state.error!);
        } else if (state.status == ViewStatus.success) {
          _onSuccess();
        }
      },
      builder: (context, state) {
        return AuthLayout(
          title: AuthStrings.registerHeadline,
          subtitle: AuthStrings.registerSubtitle,
          showBack: true,
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AuthStrings.haveAccount, style: AppTextStyles.bodySmall),
              AppButton.text(
                label: AuthStrings.loginAction,
                size: AppButtonSize.small,
                onPressed: state.isLoading ? null : () => context.router.maybePop(),
              ),
            ],
          ),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AuthStrings.registerTitle, style: AppTextStyles.title),
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
                    onSubmitted: (_) => _submit(),
                  ),
                  const Gap(AppSpacing.lg),
                  AppButton(
                    label: AuthStrings.registerAction,
                    expand: true,
                    loading: state.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
