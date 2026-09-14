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
import '../domain/entities/hotel_chain.dart';
import '../domain/usecases/hotel_chain_usecases.dart';

/// Tên, giới thiệu của chuỗi và vùng xoá chuỗi.
@RoutePage()
class ChainInfoScreen extends StatefulWidget {
  const ChainInfoScreen({super.key, required this.chainId});

  final int chainId;

  @override
  State<ChainInfoScreen> createState() => _ChainInfoScreenState();
}

class _ChainInfoScreenState extends State<ChainInfoScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  late Future<HotelChainDetail> _detail = _load();
  HotelChain? _chain;
  bool _saving = false;

  Future<HotelChainDetail> _load() async {
    final detail = await getIt<GetHotelChainDetail>()(widget.chainId);
    _name.text = detail.chain.name;
    _description.text = detail.chain.description;
    if (mounted) setState(() => _chain = detail.chain);
    return detail;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save(HotelChain chain) async {
    if (!_form.currentState!.validate()) return;
    final sessionCubit = context.read<SessionCubit>();
    setState(() => _saving = true);
    final result = await runAction(
      () => getIt<UpdateHotelChain>()(
        chain,
        name: _name.text,
        description: _description.text,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!result.isSuccess) {
      AppToast.error(context, result.error!);
      return;
    }
    final session = sessionCubit.session;
    if (session != null) await sessionCubit.update(session.copyWith(hotelChain: result.value));
    if (!mounted) return;
    AppToast.success(context, ManagementStrings.chainSaved);
    await context.router.maybePop(true);
  }

  Future<void> _delete(HotelChain chain) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: ManagementStrings.deleteChain,
      message: ManagementStrings.deleteChainMessage,
      confirmLabel: AppStrings.delete,
      destructive: true,
      icon: Icons.warning_amber_rounded,
    );
    if (!confirmed || !mounted) return;
    final sessionCubit = context.read<SessionCubit>();
    final router = context.router.root;
    final result = await AppAction.run(
      context,
      () => runAction(() => getIt<DeleteHotelChain>()(chain.id)),
      successMessage: AppStrings.deleted,
    );
    if (!result.isSuccess) return;
    final session = sessionCubit.session;
    if (session != null) {
      // Giữ accountId để tạo lại chuỗi mà không phải đăng nhập lại.
      await sessionCubit.update(
        session.copyWith(clearChain: true, accountId: session.resolvedAccountId),
      );
    }
    await router.replaceAll([const CreateChainRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final chain = _chain;
    return AppPage(
      title: ManagementStrings.chainInfoTitle,
      body: FutureBuilder<HotelChainDetail>(
        future: _detail,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppFailureView.fromError(
              snapshot.error!,
              onRetry: () => setState(() => _detail = _load()),
            );
          }
          if (!snapshot.hasData) return const AppLoadingView();
          final loaded = snapshot.data!.chain;
          return Form(
            key: _form,
            child: ListView(
              padding: AppSpacing.page,
              children: [
                const GroupLabel(ManagementStrings.chainInfoTitle),
                AppTextField(
                  controller: _name,
                  label: ManagementStrings.chainName,
                  prefixIcon: Icons.apartment_rounded,
                  textCapitalization: TextCapitalization.words,
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
                const Gap(AppSpacing.xxl),
                AppCard(
                  borderColor: AppColors.danger.withValues(alpha: 0.35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        ManagementStrings.dangerZone,
                        style: AppTextStyles.subtitle.colored(AppColors.danger),
                      ),
                      const Gap(4),
                      Text(ManagementStrings.deleteChainMessage, style: AppTextStyles.bodySmall),
                      const Gap(AppSpacing.md),
                      AppButton(
                        variant: AppButtonVariant.dangerOutline,
                        label: ManagementStrings.deleteChain,
                        icon: Icons.delete_forever_outlined,
                        onPressed: () => _delete(loaded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: AppStrings.saveChanges,
          expand: true,
          loading: _saving,
          onPressed: chain == null ? null : () => _save(chain),
        ),
      ),
    );
  }
}
