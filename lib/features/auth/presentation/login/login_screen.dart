import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/component/component.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/style/style.dart';
import '../../../../core/text/auth_strings.dart';
import '../../../../core/utils/validators.dart';
import '../session/session_navigator.dart';
import '../widgets/auth_layout.dart';
import 'login_cubit.dart';

/// [returnResult]: mở từ cổng đăng nhập (đặt phòng, yêu thích) — đăng nhập
/// xong quay lại màn trước thay vì về trang nhà.
@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.returnResult = false});

  final bool returnResult;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: _LoginView(returnResult: returnResult),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({required this.returnResult});

  final bool returnResult;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().submit(
          username: _username.text,
          password: _password.text,
        );
  }

  Future<void> _onSuccess(AuthFormState state) async {
    final session = state.session!;
    if (widget.returnResult && session.role == Role.customer) {
      await context.router.maybePop(true);
      return;
    }
    final error = await SessionNavigator.goHome(context, session);
    if (error != null && mounted) AppToast.error(context, error);
  }

  Future<void> _openRegister() async {
    final registered = await context.router.push<bool>(
      RegisterRoute(returnResult: widget.returnResult),
    );
    if (registered == true && mounted && widget.returnResult) {
      await context.router.maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, AuthFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ViewStatus.failure) {
          AppToast.error(context, state.error!);
        } else if (state.status == ViewStatus.success) {
          _onSuccess(state);
        }
      },
      builder: (context, state) {
        return AuthLayout(
          title: AuthStrings.loginHeadline,
          subtitle: AuthStrings.loginSubtitle,
          showBack: context.router.canPop(),
          footer: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AuthStrings.noAccount, style: AppTextStyles.bodySmall),
                  AppButton.text(
                    label: AuthStrings.createAccount,
                    size: AppButtonSize.small,
                    onPressed: state.isLoading ? null : _openRegister,
                  ),
                ],
              ),
              if (!widget.returnResult)
                AppButton.text(
                  label: AuthStrings.browseAsGuest,
                  icon: Icons.travel_explore_rounded,
                  onPressed: state.isLoading
                      ? null
                      : () => context.router.replaceAll([const CustomerShellRoute()]),
                ),
            ],
          ),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AuthStrings.loginTitle, style: AppTextStyles.title),
                  const Gap(AppSpacing.md),
                  AppTextField(
                    controller: _username,
                    label: AuthStrings.username,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    validator: Validators.required(),
                  ),
                  const Gap(AppSpacing.sm),
                  AppPasswordField(
                    controller: _password,
                    label: AuthStrings.password,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: Validators.required(),
                    onSubmitted: (_) => _submit(),
                  ),
                  const Gap(AppSpacing.lg),
                  AppButton(
                    label: AuthStrings.loginAction,
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
