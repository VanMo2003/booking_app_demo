import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/style/style.dart';
import '../../../core/text/auth_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';
import '../data/models/account_models.dart';
import '../domain/repositories/account_repository.dart';

/// Mục "Đổi mật khẩu" trong menu tài khoản - dùng chung cho mọi vai trò.
class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuTile(
      icon: Icons.lock_reset_rounded,
      title: AuthStrings.changePassword,
      onTap: () => AppDialogs.sheet<void>(
        context,
        title: AuthStrings.changePassword,
        builder: (_) => const ChangePasswordForm(),
      ),
    );
  }
}

/// BE đòi mật khẩu hiện tại và kết thúc mọi phiên cũ khi đổi xong, nên đổi
/// thành công thì đăng xuất để người dùng đăng nhập lại bằng mật khẩu mới.
class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final accountId =
        context.read<SessionCubit>().state.session?.resolvedAccountId;
    if (accountId == null) return;
    setState(() => _busy = true);
    try {
      await getIt<AccountRepository>().update(
        accountId,
        AccountUpdateRequest(
            password: _next.text, currentPassword: _current.text),
      );
      if (!mounted) return;
      AppToast.success(context, AuthStrings.passwordChanged);
      Navigator.of(context).pop();
      await SessionNavigator.logout(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppToast.error(context, AppException.from(error).message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AuthStrings.changePasswordHint, style: AppTextStyles.bodySmall),
          const Gap(AppSpacing.md),
          AppPasswordField(
            controller: _current,
            label: AuthStrings.currentPassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
            validator: Validators.required(),
          ),
          const Gap(AppSpacing.sm),
          AppPasswordField(
            controller: _next,
            label: AuthStrings.newPassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: Validators.password,
          ),
          const Gap(AppSpacing.sm),
          AppPasswordField(
            controller: _confirm,
            label: AuthStrings.confirmPassword,
            textInputAction: TextInputAction.done,
            validator: Validators.confirmPassword(_next),
            onSubmitted: (_) => _submit(),
          ),
          const Gap(AppSpacing.lg),
          AppButton(
            label: AuthStrings.changePassword,
            icon: Icons.lock_reset_rounded,
            expand: true,
            loading: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
