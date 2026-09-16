import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/style/style.dart';
import '../../../core/text/app_strings.dart';
import '../../../core/text/partner_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../hotel_chain/domain/entities/hotel_chain.dart';
import '../../partner/domain/usecases/partner_usecases.dart';
import '../../partner/presentation/widgets/review_note.dart';

@injectable
class OwnerRegistrationCubit extends LoadCubit<HotelChain> {
  OwnerRegistrationCubit(this._getRegistration);

  final GetOwnerRegistration _getRegistration;
  late int _id;

  /// [initial] là bản trong danh sách — hiện ngay trong lúc tải bản mới nhất.
  Future<void> start(int id, HotelChain? initial) {
    _id = id;
    if (initial != null) emit(LoadState(status: ViewStatus.success, data: initial));
    return load();
  }

  @override
  Future<void> load() => guard(() => _getRegistration(_id));
}

/// Chi tiết hồ sơ đăng ký chủ khách sạn; quản trị viên duyệt hoặc từ chối kèm lý do.
/// Trả `true` khi đã xử lý.
@RoutePage()
class OwnerRegistrationDetailScreen extends StatelessWidget {
  const OwnerRegistrationDetailScreen({super.key, required this.chainId, this.initial});

  final int chainId;
  final HotelChain? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OwnerRegistrationCubit>()..start(chainId, initial),
      child: const _RegistrationDetailView(),
    );
  }
}

class _RegistrationDetailView extends StatelessWidget {
  const _RegistrationDetailView();

  Future<void> _approve(BuildContext context, HotelChain chain) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: PartnerStrings.approveTitle,
      message: PartnerStrings.approveMessage(chain.name),
      confirmLabel: PartnerStrings.approve,
      icon: Icons.verified_outlined,
    );
    if (!confirmed || !context.mounted) return;
    await _decide(context, () => getIt<ApproveOwner>()(chain.id), PartnerStrings.approvedDone);
  }

  Future<void> _reject(BuildContext context, HotelChain chain) async {
    final reason = await AppDialogs.sheet<String>(
      context,
      title: PartnerStrings.rejectTitle,
      builder: (_) => const _RejectSheet(),
    );
    if (reason == null || !context.mounted) return;
    await _decide(
      context,
      () => getIt<RejectOwner>()(chain.id, reason),
      PartnerStrings.rejectedDone,
    );
  }

  Future<void> _decide(
    BuildContext context,
    Future<HotelChain> Function() decision,
    String successMessage,
  ) async {
    final cubit = context.read<OwnerRegistrationCubit>();
    final result = await AppAction.run(
      context,
      () => runAction(decision),
      successMessage: successMessage,
    );
    if (!context.mounted) return;
    if (result.isSuccess) {
      await context.router.maybePop(true);
    } else {
      // Có thể quản trị viên khác vừa xử lý hồ sơ này — tải lại trạng thái mới.
      await cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerRegistrationCubit, LoadState<HotelChain>>(
      builder: (context, state) {
        final cubit = context.read<OwnerRegistrationCubit>();
        final chain = state.data;
        return AppPage(
          title: PartnerStrings.detailTitle,
          subtitle: chain?.name,
          body: LoadStateView<HotelChain>(
            state: state,
            onRetry: cubit.load,
            builder: (context, data) => RefreshIndicator(
              onRefresh: cubit.load,
              child: _RegistrationBody(chain: data),
            ),
          ),
          bottomBar: chain == null || chain.approvalStatus != ApprovalStatus.pending
              ? null
              : BottomActionBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          variant: AppButtonVariant.dangerOutline,
                          label: PartnerStrings.reject,
                          icon: Icons.close_rounded,
                          onPressed: () => _reject(context, chain),
                        ),
                      ),
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: PartnerStrings.approve,
                          icon: Icons.check_rounded,
                          onPressed: () => _approve(context, chain),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _RegistrationBody extends StatelessWidget {
  const _RegistrationBody({required this.chain});

  final HotelChain chain;

  static String _orPlaceholder(String? value) =>
      (value ?? '').trim().isEmpty ? AppStrings.notUpdated : value!;

  @override
  Widget build(BuildContext context) {
    final status = chain.approvalStatus;
    final reason = chain.rejectionReason;
    return ListView(
      padding: AppSpacing.page,
      children: [
        AppCard(
          child: Row(
            children: [
              AppAvatar(name: chain.name, size: 52, tone: status.tone),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chain.name,
                      style: AppTextStyles.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(6),
                    StatusBadge.approval(status, dense: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (reason != null && status != ApprovalStatus.approved) ...[
          const Gap(AppSpacing.sm),
          ReviewNote(
            title: status == ApprovalStatus.rejected
                ? PartnerStrings.rejectionReason
                : PartnerStrings.previousRejection,
            text: reason,
            tone: status == ApprovalStatus.rejected ? StatusTone.danger : StatusTone.info,
          ),
        ],
        const Gap(AppSpacing.lg),
        const GroupLabel(PartnerStrings.hotelSection),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.apartment_rounded,
                label: PartnerStrings.labelHotel,
                value: chain.name,
              ),
              InfoRow(
                icon: Icons.location_on_outlined,
                label: PartnerStrings.labelAddress,
                value: _orPlaceholder(chain.address),
              ),
              InfoRow(
                icon: Icons.phone_outlined,
                label: PartnerStrings.labelPhone,
                value: _orPlaceholder(chain.phone),
              ),
            ],
          ),
        ),
        if (chain.description.isNotEmpty) ...[
          const Gap(AppSpacing.sm),
          ExpandableText(chain.description),
        ],
        const Gap(AppSpacing.lg),
        const GroupLabel(PartnerStrings.ownerSection),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.person_outline_rounded,
                label: PartnerStrings.labelOwner,
                value: _orPlaceholder(chain.ownerName),
              ),
              InfoRow(
                icon: Icons.mail_outline_rounded,
                label: PartnerStrings.labelEmail,
                value: _orPlaceholder(chain.email),
              ),
              InfoRow(
                icon: Icons.badge_outlined,
                label: PartnerStrings.labelAccount,
                value: chain.ownerUsername == null
                    ? AppStrings.notUpdated
                    : '@${chain.ownerUsername}',
              ),
              InfoRow(
                icon: Icons.schedule_rounded,
                label: PartnerStrings.labelSubmitted,
                value: chain.submittedAt == null
                    ? AppStrings.notUpdated
                    : Fmt.dateTime(chain.submittedAt),
              ),
              if (chain.reviewedAt != null)
                InfoRow(
                  icon: Icons.task_alt_rounded,
                  label: PartnerStrings.labelReviewed,
                  value: Fmt.dateTime(chain.reviewedAt),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Nhập lý do từ chối; trả lý do đã nhập hoặc `null` khi đóng.
class _RejectSheet extends StatefulWidget {
  const _RejectSheet();

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _append(String text) {
    final current = _reason.text.trim();
    final next = current.isEmpty ? text : '$current. $text';
    _reason.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(PartnerStrings.rejectHint, style: AppTextStyles.bodySmall),
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final reason in PartnerStrings.quickReasons)
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 16),
                  label: Text(reason, style: AppTextStyles.chip),
                  onPressed: () => _append(reason),
                ),
            ],
          ),
          const Gap(AppSpacing.md),
          AppTextField(
            controller: _reason,
            label: PartnerStrings.rejectReason,
            minLines: 3,
            maxLines: 5,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            validator: Validators.required(PartnerStrings.rejectReasonRequired),
          ),
          const Gap(AppSpacing.md),
          AppButton(
            variant: AppButtonVariant.danger,
            label: PartnerStrings.rejectSubmit,
            icon: Icons.send_rounded,
            expand: true,
            onPressed: () {
              if (_form.currentState!.validate()) {
                Navigator.of(context).pop(_reason.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}
