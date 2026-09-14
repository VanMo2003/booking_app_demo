import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/management_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';
import '../domain/usecases/hotel_chain_usecases.dart';

/// Chủ khách sạn chưa có chuỗi: tạo chuỗi trước khi mở cơ sở.
@RoutePage()
class CreateChainScreen extends StatefulWidget {
  const CreateChainScreen({super.key});

  @override
  State<CreateChainScreen> createState() => _CreateChainScreenState();
}

class _CreateChainScreenState extends State<CreateChainScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final sessionCubit = context.read<SessionCubit>();
    final session = sessionCubit.session;
    final accountId = session?.resolvedAccountId;
    if (session == null || accountId == null) {
      AppToast.error(context, ManagementStrings.accountMissing);
      return;
    }
    setState(() => _saving = true);
    final result = await runAction(
      () => getIt<CreateHotelChain>()(
        name: _name.text,
        description: _description.text,
        ownerAccountId: accountId,
      ),
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() => _saving = false);
      AppToast.error(context, result.error!);
      return;
    }
    await sessionCubit.update(session.copyWith(hotelChain: result.value));
    if (!mounted) return;
    AppToast.success(context, ManagementStrings.chainCreated);
    await context.router.replaceAll([const OwnerShellRoute()]);
  }

  Future<void> _logout() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutMessage,
      confirmLabel: AppStrings.logout,
      destructive: true,
    );
    if (confirmed && mounted) await SessionNavigator.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    final onDarkMuted = AppColors.onPrimary.withValues(alpha: 0.82);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GradientHeader(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 48, onDark: true),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _logout,
                      style: TextButton.styleFrom(foregroundColor: AppColors.onPrimary),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(AppStrings.logout),
                    ),
                  ],
                ),
                const Gap(AppSpacing.xl),
                Text(
                  ManagementStrings.createChainHeadline,
                  style: AppTextStyles.headline.colored(AppColors.onPrimary),
                ),
                const Gap(AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Text(
                    ManagementStrings.createChainSubtitle,
                    style: AppTextStyles.body.colored(onDarkMuted),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(ManagementStrings.createChainTitle, style: AppTextStyles.title),
                    const Gap(AppSpacing.md),
                    AppTextField(
                      controller: _name,
                      label: ManagementStrings.chainName,
                      prefixIcon: Icons.apartment_rounded,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: Validators.required(),
                    ),
                    const Gap(AppSpacing.sm),
                    AppTextField(
                      controller: _description,
                      label: ManagementStrings.chainDescription,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const Gap(AppSpacing.lg),
                    AppButton(
                      label: ManagementStrings.createChainAction,
                      icon: Icons.add_business_rounded,
                      expand: true,
                      loading: _saving,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
