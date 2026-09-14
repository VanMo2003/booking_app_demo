import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/auth_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/usecases/hotel_chain_usecases.dart';
import 'chain_cubits.dart';

/// Tài khoản quản lý của chuỗi.
@RoutePage()
class ManagersScreen extends StatelessWidget {
  const ManagersScreen({super.key, required this.chainId});

  final int chainId;

  @override
  Widget build(BuildContext context) {
    final ownerUsername = context.read<SessionCubit>().session?.username ?? '';
    return BlocProvider(
      create: (_) => getIt<ManagersCubit>()
        ..start(chainId: chainId, ownerUsername: ownerUsername),
      child: const _ManagersView(),
    );
  }
}

class _ManagersView extends StatelessWidget {
  const _ManagersView();

  Future<void> _create(BuildContext context) async {
    final created = await AppDialogs.sheet<bool>(
      context,
      title: ManagementStrings.createManager,
      builder: (_) => const _ManagerForm(),
    );
    if (created != true || !context.mounted) return;
    AppToast.success(context, ManagementStrings.managerCreated);
    await context.read<ManagersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagersCubit, LoadState<List<ManagerSummary>>>(
      builder: (context, state) {
        final cubit = context.read<ManagersCubit>();
        return AppPage(
          title: ManagementStrings.managersTitle,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _create(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text(ManagementStrings.createManager),
          ),
          body: LoadStateView<List<ManagerSummary>>(
            state: state,
            onRetry: cubit.load,
            builder: (context, managers) => RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, AppSpacing.bottomBarClearance),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.infoSoft,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: IconText(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.info,
                      text: ManagementStrings.managersGap,
                      maxLines: 4,
                      style: AppTextStyles.bodySmall.colored(AppColors.info),
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  if (managers.isEmpty)
                    const AppEmptyView(
                      icon: Icons.manage_accounts_outlined,
                      title: ManagementStrings.managersEmpty,
                    )
                  else
                    for (final manager in managers) ...[
                      _ManagerCard(summary: manager),
                      const Gap(AppSpacing.xs),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.summary});

  final ManagerSummary summary;

  @override
  Widget build(BuildContext context) {
    final account = summary.account;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(name: account.username, size: 42, tone: StatusTone.info),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.username, style: AppTextStyles.bodyStrong),
                    Text(
                      ManagementStrings.managedBranches(summary.branches.length),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (!account.active)
                const SoftTag(label: ManagementStrings.accountLocked, tone: StatusTone.danger),
            ],
          ),
          if (summary.branches.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final branch in summary.branches)
                  SoftTag(label: branch.name, icon: Icons.apartment_rounded),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ManagerForm extends StatefulWidget {
  const _ManagerForm();

  @override
  State<_ManagerForm> createState() => _ManagerFormState();
}

class _ManagerFormState extends State<_ManagerForm> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ownerUsername = context.read<SessionCubit>().session?.username ?? '';
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await runAction(
      () => getIt<CreateManagerAccount>()(
        username: _username.text,
        password: _password.text,
        ownerUsername: ownerUsername,
      ),
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = result.error;
      });
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
          AppTextField(
            controller: _username,
            label: ManagementStrings.managerUsername,
            helper: AuthStrings.usernameHint,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: Validators.username,
          ),
          const Gap(AppSpacing.sm),
          AppPasswordField(
            controller: _password,
            label: ManagementStrings.managerPassword,
            validator: Validators.password,
          ),
          if (_error != null) ...[
            const Gap(AppSpacing.sm),
            Text(_error!, style: AppTextStyles.bodySmall.colored(AppColors.danger)),
          ],
          const Gap(AppSpacing.lg),
          AppButton(
            label: ManagementStrings.createManager,
            expand: true,
            loading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
